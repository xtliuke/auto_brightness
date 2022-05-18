import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "自动亮度",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: getInitRoute(),
      getPages: AppPages.routes,
    ),
  );
}

String getInitRoute() {
  if (GetPlatform.isWindows && !GetPlatform.isWeb) return Routes.DESKTOP;
  if (GetPlatform.isMobile && !GetPlatform.isWeb) return Routes.PHONE;
  return Routes.ERROR;
}
