import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../database/database_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user_id';
  
  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Check if user already exists
      final users = DatabaseService.userBox.values.toList();
      final existingUser = users.where((u) => u.email == email).toList();
      
      if (existingUser.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }
      
      // Create new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password,
        name: name,
        createdAt: DateTime.now(),
        lastActiveDate: DateTime.now(),
      );
      
      await DatabaseService.userBox.put(user.id, user);
      await _saveCurrentUserId(user.id);
      
      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }
  
  // Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final users = DatabaseService.userBox.values.toList();
      final user = users.where((u) => 
        u.email == email && u.password == password
      ).toList();
      
      if (user.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }
      
      // Update last active date and streak
      final currentUser = user.first;
      _updateStreak(currentUser);
      
      await _saveCurrentUserId(currentUser.id);
      
      return {'success': true, 'user': currentUser};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }
  
  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserKey);
      
      if (userId == null) return null;
      
      return DatabaseService.userBox.get(userId);
    } catch (e) {
      return null;
    }
  }
  
  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
  
  // Update user streak
  static void _updateStreak(User user) {
    final now = DateTime.now();
    final lastActive = user.lastActiveDate;
    
    if (lastActive != null) {
      final difference = now.difference(lastActive).inDays;
      
      if (difference == 1) {
        // Consecutive day
        user.currentStreak++;
        if (user.currentStreak > user.longestStreak) {
          user.longestStreak = user.currentStreak;
        }
      } else if (difference > 1) {
        // Streak broken
        user.currentStreak = 1;
      }
    } else {
      user.currentStreak = 1;
      user.longestStreak = 1;
    }
    
    user.lastActiveDate = now;
    user.save();
  }
  
  static Future<void> _saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }
}
