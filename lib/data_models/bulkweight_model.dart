class BulkWeight {
  final int id;
  final int bags;
  final double weight;
  final int cumulativeBags;
  final double cumulativeWeight;
  final String transactionId;
  final String adminEmail;
  final DateTime createdAt;

  BulkWeight({
    required this.id,
    required this.bags,
    required this.weight,
    required this.cumulativeBags,
    required this.cumulativeWeight,
    required this.transactionId,
    required this.adminEmail,
    required this.createdAt,
  });

  factory BulkWeight.fromJson(Map<String, dynamic> json) {
    return BulkWeight(
      id: json['id'],
      bags: json['bags'],
      weight: json['weight'].toDouble(),
      cumulativeBags: json['cumulativeBags'],
      cumulativeWeight: json['cumulativeWeight'].toDouble(),
      transactionId: json['transactionId'],
      adminEmail: json['adminEmail'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bags': bags,
      'weight': weight,
      'cumulativeBags': cumulativeBags,
      'cumulativeWeight': cumulativeWeight,
      'transactionId': transactionId,
      'adminEmail': adminEmail,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}