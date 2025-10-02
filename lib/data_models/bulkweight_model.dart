class BulkWeight {
  final String? id; // Make id nullable
  final double bags; // Changed bags to double
  final double weight;
  final int cumulativeBags;
  final double cumulativeWeight;
  final String transactionId;
  final String? adminEmail; // Make adminEmail nullable
  final DateTime createdAt;

  BulkWeight({
    this.id, // Nullable field in the constructor
    required this.bags,
    required this.weight,
    required this.cumulativeBags,
    required this.cumulativeWeight,
    required this.transactionId,
    this.adminEmail, // Nullable field in the constructor
    required this.createdAt,
  });

  factory BulkWeight.fromJson(Map<String, dynamic> json) {
    return BulkWeight(
      id: json['id']?.toString(), // Ensure id is a String or null
      bags: json['bags']?.toDouble() ?? 0.0, // Ensure bags is treated as a double, defaulting to 0.0
      weight: json['weight'].toDouble(),
      cumulativeBags: json['cumulativeBags'],
      cumulativeWeight: json['cumulativeWeight'].toDouble(),
      transactionId: json['transactionId'],
      adminEmail: json['adminEmail'] is String ? json['adminEmail'] : null, // Safe handling of null or non-string values
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Include id only if it's not null
      'bags': bags,
      'weight': weight,
      'cumulativeBags': cumulativeBags,
      'cumulativeWeight': cumulativeWeight,
      'transactionId': transactionId,
      'adminEmail': adminEmail, // Nullable field in toJson
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
