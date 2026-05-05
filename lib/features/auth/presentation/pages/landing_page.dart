import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'GALA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to GALA',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 64),
              FilledButton(
                onPressed: () {
                  context.read<AuthCubit>().selectMode(AuthMode.register);
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.read<AuthCubit>().selectMode(AuthMode.login);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
