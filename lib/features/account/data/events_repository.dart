import 'package:dio/dio.dart';
import 'package:gala_mobile/features/account/data/models/event.dart';
import 'package:gala_mobile/features/account/data/models/events_page.dart';

class EventsRepository {
  final Dio _dio;

  EventsRepository({required Dio dio}) : _dio = dio;

  static const _basePath = '/o/c/events';

  Future<EventsPage> listEvents() async {
    final response = await _dio.get(_basePath);
    return EventsPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Event> createEvent({
    required String name,
    required DateTime date,
    Recurrence? recurrence,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'date': _formatDate(date),
    };
    if (recurrence != null) {
      body['recurence'] = recurrence.toJson();
    }
    final response = await _dio.post(_basePath, data: body);
    return Event.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEvent(int id) async {
    await _dio.delete('$_basePath/$id');
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }
}
