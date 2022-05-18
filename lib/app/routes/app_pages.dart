import 'package:get/get.dart';

import '../modules/desktop/bindings/desktop_binding.dart';
import '../modules/desktop/views/desktop_view.dart';
import '../modules/error/bindings/error_binding.dart';
import '../modules/error/views/error_view.dart';
import '../modules/phone/bindings/phone_binding.dart';
import '../modules/phone/views/phone_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.DESKTOP,
      page: () => DesktopView(),
      binding: DesktopBinding(),
    ),
    GetPage(
      name: _Paths.PHONE,
      page: () => PhoneView(),
      binding: PhoneBinding(),
    ),
    GetPage(
      name: _Paths.ERROR,
      page: () => ErrorView(),
      binding: ErrorBinding(),
    ),
  ];
}
