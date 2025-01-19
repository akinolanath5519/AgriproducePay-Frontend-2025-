

class Commodity {
  final String id;
  final String name;
  final double rate;

  Commodity({
    required this.id,
    required this.name,
    required this.rate,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: (json['id'] ?? json['_id']).toString(), // Convert to String
      name: json['name'],
      rate: (json['rate'] is int ? (json['rate'] as int).toDouble() : json['rate']).toDouble(), // Convert to double safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
    };
  }

  // CopyWith method
  Commodity copyWith({
    String? id,
    String? name,
    double? rate,
  }) {
    return Commodity(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }
}
