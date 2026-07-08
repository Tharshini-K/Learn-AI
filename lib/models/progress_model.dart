import 'package:hive/hive.dart';

part 'progress_model.g.dart';

@HiveType(typeId: 4)
class Progress extends HiveObject {
  @HiveField(0)
  String userId;
  
  @HiveField(1)
  String category;
  
  @HiveField(2)
  int completedLessons;
  
  @HiveField(3)
  int totalLessons;
  
  @HiveField(4)
  int totalQuizzes;
  
  @HiveField(5)
  int averageScore;
  
  @HiveField(6)
  String currentDifficulty;
  
  @HiveField(7)
  DateTime lastUpdated;

  Progress({
    required this.userId,
    required this.category,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.totalQuizzes = 0,
    this.averageScore = 0,
    this.currentDifficulty = 'Beginner',
    required this.lastUpdated,
  });
}
