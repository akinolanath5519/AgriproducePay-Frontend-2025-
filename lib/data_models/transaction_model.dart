class Transaction {
  final String? id;
  final String commodityName;
  final double weight;
  final String unit;
  final String supplierName;
  final double price;
  final double rate; // Added rate field
  final DateTime? transactionDate;
  final String? userId; // userId is now a part of the transaction
  String? userName; // userName will be fetched later

  Transaction({
    this.id,
    required this.commodityName,
    required this.weight,
    required this.unit,
    required this.supplierName,
    required this.price,
    required this.rate, // Add rate to the constructor
    this.transactionDate,
    this.userId, // Added userId here
    this.userName, // Initialize userName as null
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      // Handle both 'id' and '_id' for compatibility
      id: (json['id'] ?? json['_id'])?.toString(),
      commodityName: json['commodityName'] ?? '',
      weight: (json['weight'] is int)
          ? (json['weight'] as int).toDouble()
          : json['weight']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      supplierName: json['supplierName'] ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price']?.toDouble() ?? 0.0,
      rate: (json['rate'] is int)
          ? (json['rate'] as int).toDouble()
          : json['rate']?.toDouble() ?? 0.0, // Parse rate from the JSON
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null,
      // Ensure userId is converted to String, even if it's an integer
      userId: json['userId']?.toString(),
      userName: json['userName'], // User name is included from the response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'commodityName': commodityName,
      'weight': weight,
      'unit': unit,
      'supplierName': supplierName,
      'price': price,
      'rate': rate, // Include rate in the JSON
      'transactionDate': transactionDate?.toIso8601String(),
      if (userId != null) 'userId': userId, // Include userId in the JSON
      if (userName != null) 'userName': userName, // Include userName if available
    };
  }
}
