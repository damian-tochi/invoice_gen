class AccountInfo {
  final String businessName;
  final String location;
  final String inventoryType;
  final String logoPath;
  final String phone;
  final String email;
  final String note;

  AccountInfo({
    required this.businessName,
    required this.location,
    required this.inventoryType,
    required this.logoPath,
    required this.phone,
    required this.email,
    required this.note,
  });

  AccountInfo copyWith({
    String? businessName,
    String? location,
    String? inventoryType,
    String? logoPath,
    String? phone,
    String? email,
    String? note,
  }) {
    return AccountInfo(
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      inventoryType: inventoryType ?? this.inventoryType,
      logoPath: logoPath ?? this.logoPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      note: note ?? this.note
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'location': location,
      'inventoryType': inventoryType,
      'logoPath': logoPath,
      'phone': phone,
      'email': email,
      'note': note
    };
  }

  factory AccountInfo.fromMap(Map<String, dynamic> map) {
    return AccountInfo(
      businessName: map['businessName'] ?? '',
      location: map['location'] ?? '',
      inventoryType: map['inventoryType'] ?? '',
      logoPath: map['logoPath'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      note: map['note'] ?? '',
    );
  }
}
