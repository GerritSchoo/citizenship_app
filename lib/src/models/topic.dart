import 'package:meta/meta.dart';

@immutable
class Topic {
  final String id;
  final String title;

  const Topic({required this.id, required this.title});

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(id: json['id'] as String, title: json['title'] as String);
  }
}
