class Recurrence {
  final String key;
  final String name;

  const Recurrence({required this.key, required this.name});

  factory Recurrence.fromJson(Map<String, dynamic> json) {
    return Recurrence(
      key: json['key'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'name': name};
}

class Event {
  final int id;
  final String name;
  final DateTime date;
  final Recurrence? recurrence;

  const Event({
    required this.id,
    required this.name,
    required this.date,
    this.recurrence,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final raw = json['recurence'];
    return Event(
      id: json['id'] as int,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      recurrence: raw is Map<String, dynamic> ? Recurrence.fromJson(raw) : null,
    );
  }
}
