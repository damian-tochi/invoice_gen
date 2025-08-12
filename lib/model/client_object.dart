class ClientObject {
  int? id;
  String clientName;
  String clientEmail;
  String clientPhone;
  String clientAddress;

  ClientObject({
    this.id,
    required this.clientAddress,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
    };
  }

  factory ClientObject.fromMap(Map<String, dynamic> map) {
    return ClientObject(
      id: map['id'],
      clientName: map['clientName'],
      clientEmail: map['clientEmail'],
      clientPhone: map['clientPhone'],
      clientAddress: map['clientAddress'],
    );
  }
}
