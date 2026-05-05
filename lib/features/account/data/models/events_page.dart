import 'package:gala_mobile/features/account/data/models/event.dart';

class EventsPage {
  final List<Event> items;
  final int page;
  final int lastPage;
  final int pageSize;
  final int totalCount;

  const EventsPage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.pageSize,
    required this.totalCount,
  });

  factory EventsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return EventsPage(
      items: rawItems
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? rawItems.length,
      totalCount: json['totalCount'] as int? ?? rawItems.length,
    );
  }
}
