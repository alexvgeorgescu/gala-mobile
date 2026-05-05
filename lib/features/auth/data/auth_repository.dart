import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/auth/data/models/token_response.dart';
import 'package:gala_mobile/features/auth/data/models/verification_response.dart';

class AuthRepository {
  final Dio _dio;
  final SecureStorage _storage;

  AuthRepository({required Dio dio, required SecureStorage storage})
      : _dio = dio,
        _storage = storage;

  static const _devAuthHeader = {'X-EC-Dev-Auth-Key': 'default'};

  Future<VerificationResponse> sendVerificationCode(String email) async {
    final response = await _dio.post(
      '/o/ixlr-auth/v1.0/verification-code',
      data: {'emailAddress': email},
      options: Options(headers: _devAuthHeader),
    );
    return VerificationResponse.fromJson(response.data);
  }

  Future<TokenResponse> verifyOtp({
    required String email,
    required String challengeToken,
    required String code,
    String? fullName,
  }) async {
    final response = await _dio.post(
      '/o/ixlr-auth/v1.0/token',
      data: {
        'fullName': fullName ?? '',
        'emailAddress': email,
        'challengeToken': challengeToken,
        'code': code,
      },
      options: Options(headers: _devAuthHeader),
    );
    return TokenResponse.fromJson(response.data);
  }

  Future<TokenResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/o/oauth2/token',
      data: {
        'grant_type': 'refresh_token',
        'client_id': 'mobile-phone-auth',
        'refresh_token': refreshToken,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return TokenResponse.fromRefreshJson(response.data);
  }

  Future<void> revokeToken() async {
    await _dio.post(
      '/o/ixlr-auth/v1.0/revoke',
      options: Options(headers: _devAuthHeader),
    );
  }

  Future<void> storeTokens(TokenResponse tokens,
      {required String email, String? fullName}) async {
    await Future.wait([
      _storage.writeAccessToken(tokens.accessToken),
      _storage.writeRefreshToken(tokens.refreshToken),
      _storage.writeUserEmail(email),
      if (fullName != null && fullName.isNotEmpty)
        _storage.writeUserFullName(fullName),
    ]);
  }

  Future<void> clearTokens() => _storage.deleteAll();

  Future<bool> hasValidToken() async {
    final token = await _storage.readAccessToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  Future<String?> get storedRefreshToken => _storage.readRefreshToken();
  Future<String?> get storedEmail => _storage.readUserEmail();
  Future<String?> get storedFullName => _storage.readUserFullName();

  SecureStorage get storage => _storage;
}
