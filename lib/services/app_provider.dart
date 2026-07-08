import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../models/progress_model.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../database/database_service.dart';

class AppProvider extends ChangeNotifier {
  User? _currentUser;
  List<Lesson> _lessons = [];
  List<Quiz> _quizzes = [];
  List<Progress> _progress = [];
  bool _isLoading = false;
  
  final GeminiService _geminiService = GeminiService();
  
  User? get currentUser => _currentUser;
  List<Lesson> get lessons => _lessons;
  List<Quiz> get quizzes => _quizzes;
  List<Progress> get progress => _progress;
  bool get isLoading => _isLoading;
  
  // Initialize app data
  Future<void> init() async {
    _currentUser = await AuthService.getCurrentUser();
    if (_currentUser != null) {
      await loadUserData();
    }
    notifyListeners();
  }
  
  // Load user data
  Future<void> loadUserData() async {
    _lessons = DatabaseService.lessonBox.values.toList();
    _quizzes = DatabaseService.quizBox.values
        .where((q) => q.isCompleted)
        .toList();
    _progress = DatabaseService.progressBox.values
        .where((p) => p.userId == _currentUser?.id)
        .toList();
    notifyListeners();
  }
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await AuthService.login(email: email, password: password);
    
    if (result['success']) {
      _currentUser = result['user'];
      await loadUserData();
    }
    
    _isLoading = false;
    notifyListeners();
    return result;
  }
  
  // Register
  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    
    final result = await AuthService.register(
      email: email,
      password: password,
      name: name,
    );
    
    if (result['success']) {
      _currentUser = result['user'];
      await loadUserData();
    }
    
    _isLoading = false;
    notifyListeners();
    return result;
  }
  
  // Logout
  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _lessons.clear();
    _quizzes.clear();
    _progress.clear();
    notifyListeners();
  }
  
  // Create lesson
  Future<Lesson> createLesson({
    required String title,
    required String category,
    required String difficulty,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    // Generate lesson content using Gemini
    final content = await _geminiService.generateLesson(
      topic: title,
      category: category,
      difficulty: difficulty,
    );
    
    final lesson = Lesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      difficulty: difficulty,
      estimatedTime: 5,
    );
    
    await DatabaseService.lessonBox.put(lesson.id, lesson);
    _lessons.add(lesson);
    
    _isLoading = false;
    notifyListeners();
    return lesson;
  }
  
  // Complete lesson
  Future<void> completeLesson(
    Lesson lesson, {
    bool prepareQuiz = false,
    int quizQuestionCount = 5,
  }) async {
    lesson.isCompleted = true;
    lesson.completedAt = DateTime.now();
    await lesson.save();
    
    // Update user points
    if (_currentUser != null) {
      _currentUser!.totalPoints += lesson.points;
      await _currentUser!.save();
    }
    
    await loadUserData();
    if (prepareQuiz) {
      await getOrGenerateLessonQuiz(
        lesson: lesson,
        numberOfQuestions: quizQuestionCount,
      );
    }
    notifyListeners();
  }
  
  // Generate and save quiz
  Future<Quiz> generateQuiz({
    required String lessonId,
    required String topic,
    required String difficulty,
    int numberOfQuestions = 5,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    final questions = await _geminiService.generateQuiz(
      topic: topic,
      difficulty: difficulty,
      numberOfQuestions: numberOfQuestions,
    );
    
    final quiz = Quiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lessonId: lessonId,
      questions: questions,
      totalQuestions: questions.length,
      difficulty: difficulty,
    );
    
    await DatabaseService.quizBox.put(quiz.id, quiz);
    
    _isLoading = false;
    notifyListeners();
    return quiz;
  }

  Future<Quiz> getOrGenerateLessonQuiz({
    required Lesson lesson,
    int numberOfQuestions = 5,
    bool forceNew = false,
  }) async {
    if (!forceNew) {
      final pendingQuiz = DatabaseService.quizBox.values
          .where((q) => q.lessonId == lesson.id && !q.isCompleted)
          .toList();

      if (pendingQuiz.isNotEmpty) {
        return pendingQuiz.first;
      }
    }

    return generateQuiz(
      lessonId: lesson.id,
      topic: lesson.title,
      difficulty: lesson.difficulty,
      numberOfQuestions: numberOfQuestions,
    );
  }
  
  // Complete quiz
  Future<void> completeQuiz(Quiz quiz, int score, {String? category}) async {
    quiz.isCompleted = true;
    quiz.score = score;
    quiz.completedAt = DateTime.now();
    await quiz.save();
    
    // Calculate points based on score
    int points = (score * 2); // 2 points per correct answer
    
    if (_currentUser != null) {
      _currentUser!.totalPoints += points;
      await _currentUser!.save();
    }
    
    // Update progress
    await _updateProgress(quiz, categoryOverride: category);
    
    await loadUserData();
    notifyListeners();
  }
  
  // Update progress
  Future<void> _updateProgress(Quiz quiz, {String? categoryOverride}) async {
    if (_currentUser == null) return;
    
    String? category = categoryOverride;
    if (category == null || category.isEmpty) {
      final lesson = DatabaseService.lessonBox.get(quiz.lessonId);
      category = lesson?.category;
    }
    if (category == null || category.isEmpty) return;
    
    final existingProgress = _progress.where(
      (p) => p.userId == _currentUser!.id && p.category == category
    ).toList();
    
    Progress progress;
    if (existingProgress.isEmpty) {
      progress = Progress(
        userId: _currentUser!.id,
        category: category,
        lastUpdated: DateTime.now(),
      );
    } else {
      progress = existingProgress.first;
    }
    
    progress.totalQuizzes++;
    progress.averageScore = ((progress.averageScore * (progress.totalQuizzes - 1)) + 
        ((quiz.score / quiz.totalQuestions) * 100)) ~/ progress.totalQuizzes;
    
    // Adaptive difficulty
    progress.currentDifficulty = _geminiService.getRecommendedDifficulty(
      progress.averageScore
    );
    
    progress.lastUpdated = DateTime.now();
    
    await DatabaseService.progressBox.put(
      '${progress.userId}_${progress.category}',
      progress,
    );
  }
  
  // Get lessons by category
  List<Lesson> getLessonsByCategory(String category) {
    return _lessons.where((l) => l.category == category).toList();
  }
  
  // Get progress by category
  Progress? getProgressByCategory(String category) {
    final filtered = _progress.where(
      (p) => p.userId == _currentUser?.id && p.category == category
    ).toList();
    return filtered.isEmpty ? null : filtered.first;
  }
}
