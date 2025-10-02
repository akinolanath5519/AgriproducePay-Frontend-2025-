class SackReturn {
  final String id;
  final int collectionId;
  final int bagsReturned;
  final String? proxyName;
  final int supplierId;
  final DateTime returnedAt;

  SackReturn({
    required this.id,
    required this.collectionId,
    required this.bagsReturned,
    this.proxyName,
    required this.supplierId,
    required this.returnedAt,
  });

  factory SackReturn.fromJson(Map<String, dynamic> json) {
    return SackReturn(
      id: (json['id'] ?? 0).toString(),
      collectionId: json['collectionId'] ?? 0,
      bagsReturned: json['bagsReturned'] ?? 0,
      proxyName: json['proxyName'],
      supplierId: json['supplierId'] ?? 0,
      returnedAt: DateTime.tryParse(json['returnedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'bagsReturned': bagsReturned,
      'proxyName': proxyName,
      'supplierId': supplierId,
      'returnedAt': returnedAt.toIso8601String(),
    };
  }
}