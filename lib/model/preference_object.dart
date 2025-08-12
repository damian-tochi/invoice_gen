
class PreferenceObject {
  final double taxDeduction;
  final String? signaturePath;
  final String dominantColor1;
  final String dominantColor2;

  PreferenceObject({
    required this.taxDeduction,
    this.signaturePath,
    required this.dominantColor1,
    required this.dominantColor2,
  });

  Map<String, dynamic> toMap() {
    return {
      'taxDeduction': taxDeduction,
      'signaturePath': signaturePath,
      'dominantColor1': dominantColor1,
      'dominantColor2': dominantColor2,
    };
  }

  factory PreferenceObject.fromMap(Map<String, dynamic> map) {
    return PreferenceObject(
      taxDeduction: map['taxDeduction'] ?? 0.0,
      signaturePath: map['signaturePath'],
      dominantColor1: map['dominantColor1'] ?? '#000000',
      dominantColor2: map['dominantColor2'] ?? '#000000',
    );
  }
}
