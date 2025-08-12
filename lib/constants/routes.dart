import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoice_gen/ui/screens/PreferencesPage.dart';
import 'package:invoice_gen/ui/screens/account_info.dart';
import 'package:invoice_gen/ui/screens/customers_page.dart';
import 'package:invoice_gen/ui/screens/home_screen.dart';
import 'package:invoice_gen/ui/screens/transactions_page.dart';
import '../app_block/account_cubit.dart';
import '../app_block/transactions_cubit.dart';
import '../ui/screens/create_invoice.dart';
import '../ui/screens/preview_invoice.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => BlocProvider.value(
      value: Get.find<AppBlockCubit>(),
      child: const HomePage(),
    ),
  ),

  GetPage(
    name: '/create-invoice',
    page: () => BlocProvider.value(
      value: Get.find<AppBlockCubit>(),
      child: const CreateInvoicePage(),
    ),
  ),

  GetPage(
    name: '/preview-invoice',
    page: () => BlocProvider.value(
      value: Get.find<AppBlockCubit>(),
      child: PreviewInvoicePage(),
    ),
  ),

  GetPage(
    name: '/account-info',
    page: () => BlocProvider.value(
      value: Get.find<AccountCubit>(),
      child: AccountInfoPage(),
    ),
  ),

  GetPage(
    name: '/preference-set',
    page: () => BlocProvider.value(
      value: Get.find<AccountCubit>(),
      child: PreferencePage(),
    ),
  ),

  GetPage(
    name: '/customers_page',
    page: () => BlocProvider.value(
      value: Get.find<AccountCubit>(),
      child: CustomerPage(),
    ),
  ),

  GetPage(
    name: '/transactions_page',
    page: () => BlocProvider.value(
      value: Get.find<AccountCubit>(),
      child: TransactionsPage(),
    ),
  ),

];
