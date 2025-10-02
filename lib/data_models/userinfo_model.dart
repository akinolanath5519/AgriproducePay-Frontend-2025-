class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isCurrentUser;
  final bool isBlocked; // NEW FIELD

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isCurrentUser,
    required this.isBlocked, // REQUIRED
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isCurrentUser: json['isCurrentUser'] ?? false,
      isBlocked: json['isBlocked'] ?? false, // DEFAULT FALSE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isCurrentUser': isCurrentUser,
      'isBlocked': isBlocked,
    };
  }

  // copyWith method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isCurrentUser,
    bool? isBlocked, // NEW
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
