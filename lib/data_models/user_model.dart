class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isFirstLogin;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isFirstLogin,
    required this.token,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',  // Ensure 'name' is correctly parsed
      email: json['email'] ?? 'Unknown',  // Ensure 'email' is correctly parsed
      role: json['role'] ?? 'Unknown',  // Ensure 'role' is correctly parsed
      isFirstLogin: json['isFirstLogin'] ?? false,
      token: json['token'] ?? '',  // Parse token
    );
  }

  // Method to convert the User instance back to a Map (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isFirstLogin': isFirstLogin,
      'token': token, 
    };
  }
}
