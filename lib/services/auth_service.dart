import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _usersKey = 'simulated_users_database';
  static const String _currentUserKey = 'current_user';
  static const String _userProfilesKey = 'user_profiles';

  // Simulated database of users (stored locally)
  static Future<List<User>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson != null) {
        final List<dynamic> usersList = json.decode(usersJson);
        return usersList.map((userJson) => User.fromJson(userJson as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Save users to simulated database
  static Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(users.map((user) => user.toJson()).toList());
      await prefs.setString(_usersKey, usersJson);
    } catch (e) {
      throw Exception('Failed to save users: $e');
    }
  }

  // Generate unique user ID
  static String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999);
    return 'user_${timestamp}_$randomNum';
  }

  // Register a new user
  static Future<AuthResult> register(RegisterCredentials credentials) async {
    try {
      // Validate credentials
      final validationError = credentials.validationError;
      if (validationError != null) {
        return AuthResult.failure(validationError);
      }

      // Check if user already exists
      final users = await _getUsers();
      final existingUser = users.where((user) => 
        user.username.toLowerCase() == credentials.username.toLowerCase() ||
        user.email.toLowerCase() == credentials.email.toLowerCase()
      ).firstOrNull;

      if (existingUser != null) {
        if (existingUser.username.toLowerCase() == credentials.username.toLowerCase()) {
          return AuthResult.failure('Username already exists');
        } else {
          return AuthResult.failure('Email already registered');
        }
      }

      // Create new user
      final newUser = User(
        id: _generateUserId(),
        username: credentials.username,
        email: credentials.email,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      // Add to simulated database
      users.add(newUser);
      await _saveUsers(users);

      // Set as current user
      await _setCurrentUser(newUser);

      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.failure('Registration failed: $e');
    }
  }

  // Login user
  static Future<AuthResult> login(LoginCredentials credentials) async {
    try {
      final users = await _getUsers();
      final user = users.where((user) => 
        user.username.toLowerCase() == credentials.username.toLowerCase()
      ).firstOrNull;

      if (user == null) {
        return AuthResult.failure('User not found');
      }

      // In a real app, you would verify the password hash here
      // For simulation, we'll just check if password is not empty
      if (credentials.password.isEmpty) {
        return AuthResult.failure('Invalid password');
      }

      // Update last login
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      final userIndex = users.indexWhere((u) => u.id == user.id);
      if (userIndex != -1) {
        users[userIndex] = updatedUser;
        await _saveUsers(users);
      }

      // Set as current user
      await _setCurrentUser(updatedUser);

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Login failed: $e');
    }
  }

  // Get current logged-in user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Set current user
  static Future<void> _setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_currentUserKey, userJson);
    } catch (e) {
      throw Exception('Failed to set current user: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  // Get user profile key for storage
  static String getUserProfileKey(String userId) {
    return '${_userProfilesKey}_$userId';
  }

  // Get all registered users (for debugging)
  static Future<List<User>> getAllUsers() async {
    return await _getUsers();
  }

  // Delete user account (for testing)
  static Future<AuthResult> deleteAccount(String userId) async {
    try {
      final users = await _getUsers();
      users.removeWhere((user) => user.id == userId);
      await _saveUsers(users);
      
      // Clear current user if it's the deleted user
      final currentUser = await getCurrentUser();
      if (currentUser?.id == userId) {
        await logout();
      }
      
      return AuthResult.success(currentUser!);
    } catch (e) {
      return AuthResult.failure('Failed to delete account: $e');
    }
  }

  // Update user profile
  static Future<AuthResult> updateProfile(String userId, {String? username, String? email}) async {
    try {
      final users = await _getUsers();
      final userIndex = users.indexWhere((user) => user.id == userId);
      
      if (userIndex == -1) {
        return AuthResult.failure('User not found');
      }

      // Check if new username/email already exists
      if (username != null) {
        final existingUser = users.where((user) => 
          user.id != userId && user.username.toLowerCase() == username.toLowerCase()
        ).firstOrNull;
        if (existingUser != null) {
          return AuthResult.failure('Username already exists');
        }
      }

      if (email != null) {
        final existingUser = users.where((user) => 
          user.id != userId && user.email.toLowerCase() == email.toLowerCase()
        ).firstOrNull;
        if (existingUser != null) {
          return AuthResult.failure('Email already registered');
        }
      }

      // Update user
      final updatedUser = users[userIndex].copyWith(
        username: username ?? users[userIndex].username,
        email: email ?? users[userIndex].email,
      );
      
      users[userIndex] = updatedUser;
      await _saveUsers(users);
      await _setCurrentUser(updatedUser);

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Failed to update profile: $e');
    }
  }
}
