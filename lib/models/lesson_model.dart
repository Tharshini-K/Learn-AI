import 'package:hive/hive.dart';

part 'lesson_model.g.dart';

@HiveType(typeId: 1)
class Lesson extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String content;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  String difficulty;
  
  @HiveField(5)
  int estimatedTime; // in minutes
  
  @HiveField(6)
  bool isCompleted;
  
  @HiveField(7)
  DateTime? completedAt;
  
  @HiveField(8)
  int points;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.estimatedTime,
    this.isCompleted = false,
    this.completedAt,
    this.points = 10,
  });
}
