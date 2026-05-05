import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/features/auth/data/auth_repository.dart';
import 'package:gala_mobile/features/auth/presentation/cubit/auth_state.dart';

String _friendlyError(Object e) {
  if (e is DioException) {
    final status = e.response?.statusCode;
    final path = e.requestOptions.path;
    if (status != null) {
      return 'HTTP $status on $path';
    }
    return 'Network error: ${e.type.name} ($path)';
  }
  return e.toString();
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial());

  Future<void> checkAutoLogin() async {
    try {
      if (await _repository.hasValidToken()) {
        emit(const AuthAuthenticated());
        return;
      }
      final refreshToken = await _repository.storedRefreshToken;
      if (refreshToken != null) {
        final tokens = await _repository.refreshToken(refreshToken);
        final email = await _repository.storedEmail ?? '';
        final fullName = await _repository.storedFullName;
        await _repository.storeTokens(tokens,
            email: email, fullName: fullName);
        emit(const AuthAuthenticated());
        return;
      }
    } catch (_) {
      await _repository.clearTokens();
    }
    emit(const AuthInitial());
  }

  void selectMode(AuthMode mode) {
    emit(AuthEmailInput(mode));
  }

  void backToLanding() {
    emit(const AuthInitial());
  }

  Future<void> sendOtp({
    required String email,
    required AuthMode mode,
    String? fullName,
  }) async {
    emit(const AuthLoading());
    try {
      final response = await _repository.sendVerificationCode(email);

      if (mode == AuthMode.register && response.isRegistered) {
        emit(AuthUserStatusMismatch(
          attemptedMode: mode,
          email: email,
          message: 'Email already registered, please login',
        ));
        return;
      }

      if (mode == AuthMode.login && !response.isRegistered) {
        emit(AuthUserStatusMismatch(
          attemptedMode: mode,
          email: email,
          message: 'Email not registered, please register',
        ));
        return;
      }

      emit(AuthOtpSent(
        mode: mode,
        email: email,
        challengeToken: response.challengeToken,
        codeLength: response.codeLength,
        expiresIn: response.expiresIn,
        fullName: fullName,
      ));
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> verifyOtp({
    required AuthOtpSent context,
    required String code,
  }) async {
    emit(const AuthLoading());
    try {
      final tokens = await _repository.verifyOtp(
        email: context.email,
        challengeToken: context.challengeToken,
        code: code,
        fullName: context.fullName,
      );
      await _repository.storeTokens(tokens,
          email: context.email, fullName: context.fullName);
      emit(const AuthAuthenticated());
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        emit(AuthOtpInvalid(context));
      } else if (status == 423) {
        emit(AuthOtpLocked(context));
      } else {
        emit(AuthError(_friendlyError(e)));
      }
    } catch (e) {
      emit(AuthError(_friendlyError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _repository.revokeToken();
    } catch (_) {
      // Ignore revoke errors, still clear local tokens
    }
    await _repository.clearTokens();
    emit(const AuthInitial());
  }

  void switchToSuggestedMode(AuthUserStatusMismatch mismatchState) {
    emit(AuthEmailInput(mismatchState.suggestedMode));
  }
}
