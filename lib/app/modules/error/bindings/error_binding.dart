import 'package:get/get.dart';

import '../controllers/error_controller.dart';

class ErrorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ErrorController>(
      () => ErrorController(),
    );
  }
}
