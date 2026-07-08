import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String password;
  
  @HiveField(3)
  String name;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  String? profileImage;
  
  @HiveField(6)
  int totalPoints;
  
  @HiveField(7)
  int currentStreak;
  
  @HiveField(8)
  int longestStreak;
  
  @HiveField(9)
  DateTime? lastActiveDate;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    this.profileImage,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
  });
}
