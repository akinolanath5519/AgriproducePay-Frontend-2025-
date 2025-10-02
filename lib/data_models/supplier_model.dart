class Supplier {
  final String id;
  final String name;
  final String? contact;
  final String? address;

  Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.address,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: (json['id'] ?? json['_id']).toString(), // Convert to String
      name: json['name'],
      contact: json['contact'],   // could be null
      address: json['address'],   // could be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contact,
    String? address,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
    );
  }
}
