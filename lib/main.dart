import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'app/routes/app_pages.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

Future<void> main() async {
  if (GetPlatform.isWindows && !GetPlatform.isWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await hotKeyManager.unregisterAll();
  }
  runApp(
    OKToast(
      child: GetMaterialApp(
        title: "自动亮度",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: getInitRoute(),
        getPages: AppPages.routes,
      ),
    ),
  );
  doWhenWindowReady(() {
    const initialSize = Size(680, 420);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
  });
}

String getInitRoute() {
  if (GetPlatform.isWindows && !GetPlatform.isWeb) return Routes.DESKTOP;
  if (GetPlatform.isMobile && !GetPlatform.isWeb) return Routes.PHONE;
  return Routes.ERROR;
}
