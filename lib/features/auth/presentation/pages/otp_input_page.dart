import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/otp_timer_cubit.dart';

class OtpInputPage extends StatefulWidget {
  final AuthOtpSent otpState;

  const OtpInputPage({super.key, required this.otpState});

  @override
  State<OtpInputPage> createState() => _OtpInputPageState();
}

class _OtpInputPageState extends State<OtpInputPage> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  String? _lastError;
  int _lockSeconds = 0;
  Timer? _lockTimer;

  bool get _isLocked => _lockSeconds > 0;

  @override
  void initState() {
    super.initState();
    final length = widget.otpState.codeLength;
    _controllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _clearInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  void _startLockout(int seconds) {
    _lockTimer?.cancel();
    setState(() {
      _lockSeconds = seconds;
      _lastError = null;
    });
    _clearInputs();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lockSeconds <= 1) {
        timer.cancel();
        setState(() {
          _lockSeconds = 0;
        });
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      } else {
        setState(() {
          _lockSeconds -= 1;
        });
      }
    });
  }

  void _onDigitChanged(int index) {
    if (_isLocked) return;
    if (_lastError != null) {
      setState(() => _lastError = null);
    }
    final text = _controllers[index].text;
    if (text.length == 1 && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otpCode.length == widget.otpState.codeLength) {
      _submitOtp();
    }
  }

  void _submitOtp() {
    final code = _otpCode;
    if (code.length != widget.otpState.codeLength) return;

    context.read<AuthCubit>().verifyOtp(
          context: widget.otpState,
          code: code,
        );
  }

  void _resendOtp() {
    context.read<AuthCubit>().sendOtp(
          email: widget.otpState.email,
          mode: widget.otpState.mode,
          fullName: widget.otpState.fullName,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, current) =>
          current is AuthOtpInvalid || current is AuthOtpLocked,
      listener: (_, state) {
        if (state is AuthOtpInvalid) {
          setState(() => _lastError = 'Invalid code, please try again');
          _clearInputs();
        } else if (state is AuthOtpLocked) {
          _startLockout(state.lockSeconds);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter OTP'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'OTP sent to ${widget.otpState.email}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      List.generate(widget.otpState.codeLength, (index) {
                    return Container(
                      width: 48,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        enabled: !_isLocked,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        style: const TextStyle(fontSize: 24),
                        onChanged: (_) => _onDigitChanged(index),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                if (_isLocked)
                  Text(
                    'Too many attempts. Wait ${_lockSeconds}s before trying again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                else if (_lastError != null)
                  Text(
                    _lastError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 16),
                BlocBuilder<OtpTimerCubit, int>(
                  builder: (context, seconds) {
                    if (seconds > 0) {
                      return Text(
                        'Code expires in ${seconds}s',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }
                    return TextButton(
                      onPressed: _isLocked ? null : _resendOtp,
                      child: const Text('Resend OTP'),
                    );
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthCubit, AuthState>(
                  buildWhen: (_, current) =>
                      current is AuthLoading ||
                      current is AuthOtpInvalid ||
                      current is AuthOtpLocked ||
                      current is AuthOtpSent,
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
