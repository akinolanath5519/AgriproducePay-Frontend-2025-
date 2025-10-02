class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isFirstLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isFirstLogin,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? 'Unknown',
      role: json['role'] ?? 'Unknown',
      isFirstLogin: json['isFirstLogin'] ?? false,
    );
  }

  // Convert User back to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isFirstLogin': isFirstLogin,
    };
  }
}
