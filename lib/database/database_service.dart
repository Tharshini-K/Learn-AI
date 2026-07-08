import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';
import '../utils/constants.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LessonAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(QuizAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(QuestionAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ProgressAdapter());
    }
    
    // Open Boxes
    await Hive.openBox<User>(AppConstants.userBox);
    await Hive.openBox<Lesson>(AppConstants.lessonBox);
    await Hive.openBox<Quiz>(AppConstants.quizBox);
    await Hive.openBox<Progress>(AppConstants.progressBox);
  }
  
  static Box<User> get userBox => Hive.box<User>(AppConstants.userBox);
  static Box<Lesson> get lessonBox => Hive.box<Lesson>(AppConstants.lessonBox);
  static Box<Quiz> get quizBox => Hive.box<Quiz>(AppConstants.quizBox);
  static Box<Progress> get progressBox => Hive.box<Progress>(AppConstants.progressBox);
  
  static Future<void> close() async {
    await Hive.close();
  }
}
