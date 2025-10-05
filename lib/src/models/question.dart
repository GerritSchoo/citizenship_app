class Question {
  final String id;
  final String text;
  final List<String> answers;
  final int correctIndex;
  final String topicId;
  final String explanation;
  final bool hasImage;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctIndex,
    required this.topicId,
    required this.explanation,
    this.hasImage = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      answers: List<String>.from(json['answers']),
      correctIndex: json['correctIndex'],
      topicId: json['topicId'],
      explanation: json['explanation'],
      hasImage: json['hasImage'] == true,
    );
  }
}
