import 'package:equatable/equatable.dart';

/// Single todo item in the domain model.
class Todo extends Equatable {
  /// Creates a todo with required fields.
  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  /// Deserializes from JSON map keys matching [toJson].
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  /// Stable identifier.
  final String id;

  /// User-visible title.
  final String title;

  /// Whether the todo is done.
  final bool isCompleted;
  
  /// Creation timestamp (UTC or local per serialization).
  final DateTime createdAt;

  /// Returns a copy with any field replaced.
  Todo copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, title, isCompleted, createdAt];

  /// JSON map for persistence APIs.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
