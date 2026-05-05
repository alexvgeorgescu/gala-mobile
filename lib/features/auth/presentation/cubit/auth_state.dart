import 'package:equatable/equatable.dart';

enum AuthMode { login, register }

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthEmailInput extends AuthState {
  final AuthMode mode;

  const AuthEmailInput(this.mode);

  @override
  List<Object?> get props => [mode];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOtpSent extends AuthState {
  final AuthMode mode;
  final String email;
  final String challengeToken;
  final int codeLength;
  final int expiresIn;
  final String? fullName;

  const AuthOtpSent({
    required this.mode,
    required this.email,
    required this.challengeToken,
    required this.codeLength,
    required this.expiresIn,
    this.fullName,
  });

  @override
  List<Object?> get props =>
      [mode, email, challengeToken, codeLength, expiresIn, fullName];
}

class AuthUserStatusMismatch extends AuthState {
  final AuthMode attemptedMode;
  final String email;
  final String message;

  const AuthUserStatusMismatch({
    required this.attemptedMode,
    required this.email,
    required this.message,
  });

  AuthMode get suggestedMode =>
      attemptedMode == AuthMode.register ? AuthMode.login : AuthMode.register;

  @override
  List<Object?> get props => [attemptedMode, email, message];
}

class AuthOtpInvalid extends AuthState {
  final AuthOtpSent context;

  const AuthOtpInvalid(this.context);

  @override
  List<Object?> get props => [context];
}

class AuthOtpLocked extends AuthState {
  final AuthOtpSent context;
  final int lockSeconds;

  const AuthOtpLocked(this.context, {this.lockSeconds = 60});

  @override
  List<Object?> get props => [context, lockSeconds];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
