class MarketplaceProfile {
  final String id;
  final int userId;
  final String role; // "BUYER" | "SELLER"
  final bool? active;
  final bool? verified;
  final String? phone;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketplaceProfile({
    required this.id,
    required this.userId,
    required this.role,
    this.active,
    this.verified,
    this.phone,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketplaceProfile.fromJson(Map<String, dynamic> json) {
    return MarketplaceProfile(
      id: json['id']?.toString() ?? '', // Convert to string
      userId: json['userId'] ?? 0,
      role: json['role'] ?? 'UNKNOWN',
      active: json['active'], // Optional field
      verified: json['verified'], // Optional field
      phone: json['phone'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      if (active != null) 'active': active,
      if (verified != null) 'verified': verified,
      'phone': phone,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
