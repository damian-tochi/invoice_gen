class AppBlockState {
  final int invoice;

  AppBlockState({this.invoice = 1});

  AppBlockState copyWith({int? invoice}) {
    return AppBlockState(invoice: invoice ?? this.invoice);
  }

  AppBlockState init() {
    return AppBlockState(invoice: 1);
  }

  AppBlockState clone() {
    return copyWith();
  }
}