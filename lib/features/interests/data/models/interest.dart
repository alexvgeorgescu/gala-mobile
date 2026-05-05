class InterestType {
  final String key;
  final String name;

  const InterestType({required this.key, required this.name});

  factory InterestType.fromJson(Map<String, dynamic> json) {
    return InterestType(
      key: json['key'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'name': name};
}

class Interest {
  final int id;
  final String name;
  final String description;
  final InterestType? type;

  const Interest({
    required this.id,
    required this.name,
    required this.description,
    this.type,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'];
    return Interest(
      id: json['id'] as int,
      name: json['name'] as String,
      description: (json['description'] as String?) ?? '',
      type:
          rawType is Map<String, dynamic> ? InterestType.fromJson(rawType) : null,
    );
  }
}
