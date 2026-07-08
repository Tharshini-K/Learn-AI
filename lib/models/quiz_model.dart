import 'package:hive/hive.dart';

part 'quiz_model.g.dart';

@HiveType(typeId: 2)
class Quiz extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String lessonId;
  
  @HiveField(2)
  List<Question> questions;
  
  @HiveField(3)
  int score;
  
  @HiveField(4)
  int totalQuestions;
  
  @HiveField(5)
  bool isCompleted;
  
  @HiveField(6)
  DateTime? completedAt;
  
  @HiveField(7)
  String difficulty;

  Quiz({
    required this.id,
    required this.lessonId,
    required this.questions,
    this.score = 0,
    required this.totalQuestions,
    this.isCompleted = false,
    this.completedAt,
    required this.difficulty,
  });
}

@HiveType(typeId: 3)
class Question extends HiveObject {
  @HiveField(0)
  String question;
  
  @HiveField(1)
  List<String> options;
  
  @HiveField(2)
  int correctAnswer;
  
  @HiveField(3)
  int? userAnswer;
  
  @HiveField(4)
  String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    required this.explanation,
  });
}
