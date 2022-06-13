import 'package:get/get.dart';

import '../controllers/clock_controller.dart';

class ClockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClockController>(
      () => ClockController(),
    );
  }
}
