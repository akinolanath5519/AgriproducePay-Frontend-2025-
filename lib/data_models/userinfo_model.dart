class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isCurrentUser;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isCurrentUser,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isCurrentUser': isCurrentUser,
    };
  }

  // copyWith method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isCurrentUser,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
