import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/account_service.dart';
import '../model/account_info_object.dart';

class AccountCubit extends Cubit<AccountInfo?> {
  AccountCubit() : super(null);

  Future<void> loadAccountInfo() async {
    final info = await AccountService.getAccountInfo();
    emit(info);
  }

  Future<void> updateAccountInfo(AccountInfo info) async {
    await AccountService.saveAccountInfo(info);
    emit(info);
  }
}
