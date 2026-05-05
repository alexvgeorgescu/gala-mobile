import 'package:dio/dio.dart';

String friendlyDioError(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    if (status != null) {
      return 'HTTP $status on $path';
    }
    return 'Network error: ${error.type.name} ($path)';
  }
  return error.toString();
}
