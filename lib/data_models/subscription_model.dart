class Subscription {
  final String id;
  final String userId;
  final String subscriptionStatus;
  final DateTime subscriptionExpiry;
  final int duration;
  final DateTime subscriptionStartDate;
  final String adminEmail;
  final bool isSubscribed; // Add this field to indicate if the subscription is active

  Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionStatus,
    required this.subscriptionExpiry,
    required this.duration,
    required this.subscriptionStartDate,
    required this.adminEmail,
    required this.isSubscribed, // Include isSubscribed in the constructor
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: (json['id'] ?? json['_id']).toString(),
      userId: json['userId'] ?? '',
      subscriptionStatus: json['subscriptionStatus'] ?? '',
      subscriptionExpiry: DateTime.parse(json['subscriptionExpiry'] ?? '1970-01-01'),
      duration: json['duration'] ?? 0,
      subscriptionStartDate: DateTime.parse(json['subscriptionStartDate'] ?? '1970-01-01'),
      adminEmail: json['adminEmail'] ?? '',
      isSubscribed: json['isSubscribed'] ?? false, // Parse isSubscribed from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionExpiry': subscriptionExpiry.toIso8601String(),
      'duration': duration,
      'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
      'adminEmail': adminEmail,
      'isSubscribed': isSubscribed, // Include isSubscribed in the JSON
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? subscriptionStatus,
    DateTime? subscriptionExpiry,
    int? duration,
    DateTime? subscriptionStartDate,
    String? adminEmail,
    bool? isSubscribed, // Include isSubscribed in the copyWith method
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      duration: duration ?? this.duration,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      adminEmail: adminEmail ?? this.adminEmail,
      isSubscribed: isSubscribed ?? this.isSubscribed, // Copy isSubscribed
    );
  }
}
