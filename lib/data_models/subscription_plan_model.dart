class SubscriptionPlan {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int duration; // in days
  final List<String>? features;

  SubscriptionPlan({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    this.features,
  });

  // Factory constructor to parse JSON from backend
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: (json['id'] ?? json['_id']).toString(),
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price']).toDouble(),
      duration: json['duration'] as int,
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
    );
  }

  // Convert class instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'features': features,
    };
  }

  // CopyWith method for immutability
  SubscriptionPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    List<String>? features,
  }) {
    return SubscriptionPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      features: features ?? this.features,
    );
  }
}
