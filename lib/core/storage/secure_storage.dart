import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userEmailKey = 'user_email';
  static const _userFullNameKey = 'user_full_name';

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> readAccessToken() =>
      _storage.read(key: _accessTokenKey);

  Future<void> writeRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  Future<void> writeUserEmail(String email) =>
      _storage.write(key: _userEmailKey, value: email);

  Future<String?> readUserEmail() =>
      _storage.read(key: _userEmailKey);

  Future<void> writeUserFullName(String name) =>
      _storage.write(key: _userFullNameKey, value: name);

  Future<String?> readUserFullName() =>
      _storage.read(key: _userFullNameKey);

  Future<void> deleteAll() => _storage.deleteAll();
}
