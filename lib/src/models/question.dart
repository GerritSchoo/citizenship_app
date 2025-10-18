class Question {
  final String id;
  final String text;
  final List<String> answers;
  final int correctIndex;
  final String topicId;
  final String explanation;
  final bool hasImage;
  // Optional single context image displayed with the question
  final String? image;
  // Optional list of images corresponding to each answer option (e.g., 4)
  final List<String>? answerImages;

  Question({
    required this.id,
    required this.text,
    required this.answers,
    required this.correctIndex,
    required this.topicId,
    required this.explanation,
    this.hasImage = false,
    this.image,
    this.answerImages,
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
      image: json['image'] as String?,
      answerImages: (json['answerImages'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  // Convenience flags used by UI
  bool get hasContextImage => image != null && image!.isNotEmpty;
  bool get hasAnswerImages =>
      answerImages != null && answerImages!.isNotEmpty && answerImages!.length == answers.length;
}
