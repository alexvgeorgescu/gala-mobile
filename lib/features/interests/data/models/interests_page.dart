import 'package:gala_mobile/features/interests/data/models/interest.dart';

class InterestsPage {
  final List<Interest> items;
  final int page;
  final int lastPage;
  final int pageSize;
  final int totalCount;

  const InterestsPage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.pageSize,
    required this.totalCount,
  });

  factory InterestsPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return InterestsPage(
      items: rawItems
          .map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? rawItems.length,
      totalCount: json['totalCount'] as int? ?? rawItems.length,
    );
  }
}
