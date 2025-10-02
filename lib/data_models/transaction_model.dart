class Transaction {
  final String? id;
  final String? commodityName;
  final double weight;
  final String unit;
  final String? supplierName;
  final double price;
  final double rate;
  final DateTime? transactionDate;
  final String? userId;
  String? userName;

  /// New field
  final String? commodityCondition;

  Transaction({
    this.id,
    this.commodityName,
    required this.weight,
    required this.unit,
    this.supplierName,
    required this.price,
    required this.rate,
    this.transactionDate,
    this.userId,
    this.userName,
    this.commodityCondition, // add to constructor
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
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
          : json['rate']?.toDouble() ?? 0.0,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null,
      userId: json['userId']?.toString(),
      userName: json['userName'],
      commodityCondition: json['commodityCondition'], // new
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
      'rate': rate,
      'transactionDate': transactionDate?.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (userName != null) 'userName': userName,
      if (commodityCondition != null)
        'commodityCondition': commodityCondition, // new
    };
  }

  Transaction copyWith({
    String? id,
    String? commodityName,
    double? weight,
    String? unit,
    String? supplierName,
    double? price,
    double? rate,
    DateTime? transactionDate,
    String? userId,
    String? userName,
    String? commodityCondition, // new
  }) {
    return Transaction(
      id: id ?? this.id,
      commodityName: commodityName ?? this.commodityName,
      weight: weight ?? this.weight,
      unit: unit ?? this.unit,
      supplierName: supplierName ?? this.supplierName,
      price: price ?? this.price,
      rate: rate ?? this.rate,
      transactionDate: transactionDate ?? this.transactionDate,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      commodityCondition: commodityCondition ?? this.commodityCondition, // new
    );
  }
}
