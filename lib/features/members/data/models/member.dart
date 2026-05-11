class Member {
  final int id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarURL;

  const Member({
    required this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarURL,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String?,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        email: json['email'] as String?,
        avatarURL: json['avatarURL'] as String?,
      );

  String get displayName {
    final parts = <String>[
      if (firstName != null && firstName!.isNotEmpty) firstName!,
      if (lastName != null && lastName!.isNotEmpty) lastName!,
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    return 'Member #$id';
  }

  String get initials {
    final f = (firstName != null && firstName!.isNotEmpty) ? firstName![0] : '';
    final l = (lastName != null && lastName!.isNotEmpty) ? lastName![0] : '';
    final pair = (f + l).toUpperCase();
    if (pair.isNotEmpty) return pair;
    final fallback = displayName;
    return fallback.isNotEmpty ? fallback[0].toUpperCase() : '?';
  }
}
