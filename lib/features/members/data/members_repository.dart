import 'package:dio/dio.dart';
import 'package:gala_mobile/features/members/data/models/members_page.dart';

class MembersRepository {
  final Dio _dio;

  MembersRepository({required Dio dio}) : _dio = dio;

  static const _basePath = '/o/gala/v1.0/members';

  Future<MembersPage> search({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      _basePath,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = response.data;
    if (data is List) {
      return MembersPage.fromList(data);
    }
    return MembersPage.fromJson(data as Map<String, dynamic>);
  }
}
