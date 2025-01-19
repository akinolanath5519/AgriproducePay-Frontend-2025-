class SackRecord {
  final String id;
  final String supplierName;
  final DateTime date; // Change to DateTime
  final int bagsCollected;
  final int bagsReturned;

  SackRecord({
    required this.id,
    required this.supplierName,
    required this.date, // Now accepting DateTime
    required this.bagsCollected,
    required this.bagsReturned,
  });

  int get bagsRemaining => bagsCollected - bagsReturned;

  // Parsing the string date into DateTime during object creation
  factory SackRecord.fromJson(Map<String, dynamic> json) {
    return SackRecord(
      id: (json['id'] ?? json['_id']).toString(), // Convert to String, fallback for MongoDB _id
      supplierName: json['supplierName'],
      date: DateTime.parse(json['date']), // Convert String to DateTime
      bagsCollected: json['bagsCollected'],
      bagsReturned: json['bagsReturned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierName': supplierName,
      'date': date.toIso8601String(), // Convert DateTime back to String
      'bagsCollected': bagsCollected,
      'bagsReturned': bagsReturned,
    };
  }

  SackRecord copyWith({
    String? id,
    String? supplierName,
    DateTime? date, // Accept DateTime for copying
    int? bagsCollected,
    int? bagsReturned,
  }) {
    return SackRecord(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
      date: date ?? this.date,
      bagsCollected: bagsCollected ?? this.bagsCollected,
      bagsReturned: bagsReturned ?? this.bagsReturned,
    );
  }
}
