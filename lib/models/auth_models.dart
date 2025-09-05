// Authentication models for Global Enigma game

class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime lastLogin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class AuthResult {
  final bool success;
  final String? message;
  final User? user;

  const AuthResult({
    required this.success,
    this.message,
    this.user,
  });

  factory AuthResult.success(User user) {
    return AuthResult(
      success: true,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult(
      success: false,
      message: message,
    );
  }
}

class LoginCredentials {
  final String username;
  final String password;

  const LoginCredentials({
    required this.username,
    required this.password,
  });
}

class RegisterCredentials {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterCredentials({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  bool get isValid {
    return username.isNotEmpty &&
           email.isNotEmpty &&
           password.isNotEmpty &&
           confirmPassword.isNotEmpty &&
           password == confirmPassword &&
           _isValidEmail(email) &&
           username.length >= 3 &&
           password.length >= 6;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? get validationError {
    if (username.isEmpty) return 'Username is required';
    if (username.length < 3) return 'Username must be at least 3 characters';
    if (email.isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Please enter a valid email';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }
}
