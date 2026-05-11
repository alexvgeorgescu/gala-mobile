import 'package:gala_mobile/features/members/data/models/member.dart';

class MembersPage {
  final List<Member> items;
  final int page;
  final int lastPage;
  final int pageSize;
  final int totalCount;

  const MembersPage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.pageSize,
    required this.totalCount,
  });

  factory MembersPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return MembersPage(
      items: rawItems
          .map((e) => Member.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
      page: json['page'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? rawItems.length,
      totalCount: json['totalCount'] as int? ?? rawItems.length,
    );
  }

  factory MembersPage.fromList(List<dynamic> list) {
    final items = list
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    return MembersPage(
      items: items,
      page: 1,
      lastPage: 1,
      pageSize: items.length,
      totalCount: items.length,
    );
  }
}
