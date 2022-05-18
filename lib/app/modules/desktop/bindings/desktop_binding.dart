import 'package:get/get.dart';

import '../controllers/desktop_controller.dart';

class DesktopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DesktopController>(
      () => DesktopController(),
    );
  }
}
