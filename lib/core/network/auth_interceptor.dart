import 'package:dio/dio.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/auth/data/models/token_response.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final SecureStorage _storage;
  final void Function()? onForceLogout;

  AuthInterceptor({
    required Dio dio,
    required SecureStorage storage,
    this.onForceLogout,
  })  : _dio = dio,
        _storage = storage;

  static const _unauthenticatedPaths = [
    '/o/ixlr-auth/v1.0/verification-code',
    '/o/ixlr-auth/v1.0/token',
    '/o/oauth2/token',
  ];

  bool _isUnauthenticated(String path) {
    return _unauthenticatedPaths.any((p) => path.contains(p));
  }

  bool _isIxlrAuthPath(String path) {
    return path.contains('/ixlr-auth/');
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isIxlrAuthPath(options.path)) {
      options.headers['X-EC-Dev-Auth-Key'] = 'default';
    }

    if (!_isUnauthenticated(options.path)) {
      final token = await _storage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        _isUnauthenticated(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) {
        _forceLogout();
        handler.next(err);
        return;
      }

      final response = await _dio.post(
        '/o/oauth2/token',
        data: {
          'grant_type': 'refresh_token',
          'client_id': 'mobile-phone-auth',
          'refresh_token': refreshToken,
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      final tokens = TokenResponse.fromRefreshJson(response.data);
      await _storage.writeAccessToken(tokens.accessToken);
      await _storage.writeRefreshToken(tokens.refreshToken);

      // Retry the original request with new token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      _forceLogout();
      handler.next(err);
    }
  }

  void _forceLogout() {
    _storage.deleteAll();
    onForceLogout?.call();
  }
}
