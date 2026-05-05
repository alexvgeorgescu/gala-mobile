import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/otp_timer_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/pages/landing_page.dart';
import 'package:gala_mobile/features/auth/presentation/pages/email_input_page.dart';
import 'package:gala_mobile/features/auth/presentation/pages/otp_input_page.dart';
import 'package:gala_mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:gala_mobile/features/profile/presentation/pages/profile_page.dart';

GoRouter createRouter(AuthCubit authCubit, SecureStorage storage) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final currentPath = state.matchedLocation;

      if (isAuthenticated && currentPath != '/profile') {
        return '/profile';
      }
      if (!isAuthenticated && currentPath == '/profile') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/auth/email',
        builder: (context, state) => const EmailInputPage(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final otpState = (state.extra as AuthOtpSent?) ??
              _otpContextOf(authCubit.state);
          if (otpState == null) {
            return const Scaffold(
              body: Center(child: Text('Lost OTP context')),
            );
          }
          return BlocProvider(
            create: (_) => OtpTimerCubit()..start(otpState.expiresIn),
            child: OtpInputPage(otpState: otpState),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (context) => ProfileCubit(storage: storage),
          child: const ProfilePage(),
        ),
      ),
    ],
  );
}

AuthOtpSent? _otpContextOf(AuthState state) {
  return switch (state) {
    AuthOtpSent s => s,
    AuthOtpInvalid s => s.context,
    AuthOtpLocked s => s.context,
    _ => null,
  };
}

class _AuthRefreshNotifier extends ChangeNotifier {
  bool _wasAuthenticated;

  _AuthRefreshNotifier(AuthCubit cubit)
      : _wasAuthenticated = cubit.state is AuthAuthenticated {
    cubit.stream.listen((state) {
      final isAuth = state is AuthAuthenticated;
      if (isAuth != _wasAuthenticated) {
        _wasAuthenticated = isAuth;
        notifyListeners();
      }
    });
  }
}
