import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'app_block/account_cubit.dart';
import 'app_block/transactions_cubit.dart';
import 'constants/routes.dart';
import 'helper/transaction_id_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TransactionIdManager.init();
  Get.put(AppBlockCubit());
  Get.put(AccountCubit());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Invoice Generator',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: appRoutes,
      navigatorObservers: [
        HeroController(
          createRectTween: (begin, end) =>
              LinearRectTween(begin: begin, end: end),
        ),
      ],
    );
  }
}

class LinearRectTween extends RectTween {
  LinearRectTween({Rect? begin, Rect? end}) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    return Rect.lerp(begin, end, t)!;
  }
}
