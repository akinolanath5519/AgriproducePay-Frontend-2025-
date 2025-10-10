class BulkWeight {
  final String id;
  final int? supplierId;
  final int? companyId;
  final String transactionRef;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  final List<BulkWeightEntry> entries;

  // Computed values (from backend response, not stored in DB directly)
  final int? totalBags;
  final double? grossWeight;
  final double? netWeight;
  final int? tare;

  BulkWeight({
    required this.id,
    this.supplierId,
    this.companyId,
    required this.transactionRef,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.entries = const [],
    this.totalBags,
    this.grossWeight,
    this.netWeight,
    this.tare,
  });

  factory BulkWeight.fromJson(Map<String, dynamic> json) {
    return BulkWeight(
      id: (json['id'] ?? 0).toString(),
      supplierId: json['supplierId'],
      companyId: json['companyId'],
      transactionRef: json['transactionRef'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      
      entries: (json['entries'] as List<dynamic>? ?? [])
          .map((e) => BulkWeightEntry.fromJson(e))
          .toList(),
      totalBags: json['totalBags'],
      grossWeight: (json['grossWeight'] as num?)?.toDouble(),
      netWeight: (json['netWeight'] as num?)?.toDouble(),
      tare: json['tare'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'companyId': companyId,
      'transactionRef': transactionRef,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'totalBags': totalBags,
      'grossWeight': grossWeight,
      'netWeight': netWeight,
      'tare': tare,
    };
  }
}




class BulkWeightEntry {
  final String id;
  final int? bulkWeightId;
  final String transactionRef;
  final int bags;
  final double weight;
  final DateTime createdAt;

  BulkWeightEntry({
    required this.id,
    this.bulkWeightId,
    required this.transactionRef,
    required this.bags,
    required this.weight,
    required this.createdAt,
  });

  factory BulkWeightEntry.fromJson(Map<String, dynamic> json) {
    return BulkWeightEntry(
      id: (json['id'] ?? 0).toString(),
      bulkWeightId: json['bulkWeightId'],
      transactionRef: json['transactionRef'] ?? '',
      bags: json['bags'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bulkWeightId': bulkWeightId,
      'transactionRef': transactionRef,
      'bags': bags,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
