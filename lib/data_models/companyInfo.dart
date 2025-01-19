

class CompanyInfo {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;

  CompanyInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      id: (json['id'] ?? json['_id']).toString(), // Convert to String
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  // CopyWith method
  CompanyInfo copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
  }) {
    return CompanyInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}
