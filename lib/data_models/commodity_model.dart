class Commodity {
  final String id;
  final String name;
  final double rate;
  final double? moisture;
  final String? condition;
  final String createdAt;
  final String updatedAt;
  final bool isSynced; // Added

  Commodity({
    required this.id, // ID always required (server or temp)
    required this.name,
    required this.rate,
    this.moisture,
    this.condition,
    String? createdAt,
    String? updatedAt,
    this.isSynced = false,
  })  : createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'].toString(),
      name: json['name'],
      rate: (json['rate'] is int ? (json['rate'] as int).toDouble() : (json['rate'] as num).toDouble()),
      moisture: json['moisture'] != null
          ? (json['moisture'] is int ? (json['moisture'] as int).toDouble() : (json['moisture'] as num).toDouble())
          : null,
      condition: json['condition'],
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
      isSynced: json['isSynced'] == true || json['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'moisture': moisture,
      'condition': condition,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced,
    };
  }

  Commodity copyWith({
    String? id,
    String? name,
    double? rate,
    double? moisture,
    String? condition,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
  }) {
    return Commodity(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      moisture: moisture ?? this.moisture,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
