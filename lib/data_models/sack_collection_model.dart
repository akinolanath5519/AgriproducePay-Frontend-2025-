class SackCollection {
  final String id;
  final int supplierId;
  final int bagsCollected;
  final String? proxyName;
  final DateTime collectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  SackCollection({
    required this.id,
    required this.supplierId,
    required this.bagsCollected,
    this.proxyName,
    required this.collectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SackCollection.fromJson(Map<String, dynamic> json) {
    return SackCollection(
      id: (json['id'] ?? 0).toString(),
      supplierId: json['supplierId'] ?? 0,
      bagsCollected: json['bagsCollected'] ?? 0,
      proxyName: json['proxyName'],
      collectedAt: DateTime.tryParse(json['collectedAt'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'bagsCollected': bagsCollected,
      'proxyName': proxyName,
      'collectedAt': collectedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
