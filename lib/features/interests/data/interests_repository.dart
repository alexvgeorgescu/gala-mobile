import 'package:dio/dio.dart';
import 'package:gala_mobile/features/interests/data/models/interest.dart';
import 'package:gala_mobile/features/interests/data/models/interests_page.dart';

class InterestsRepository {
  final Dio _dio;

  InterestsRepository({required Dio dio}) : _dio = dio;

  static const _basePath = '/o/c/interests';

  Future<InterestsPage> listInterests() async {
    final response = await _dio.get(_basePath);
    return InterestsPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Interest> createInterest({
    required String name,
    required String description,
    required InterestType type,
  }) async {
    final response = await _dio.post(_basePath, data: {
      'name': name,
      'description': description,
      'type': type.toJson(),
    });
    return Interest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteInterest(int id) async {
    await _dio.delete('$_basePath/$id');
  }
}
