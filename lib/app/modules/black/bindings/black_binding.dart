import 'package:get/get.dart';

import '../controllers/black_controller.dart';

class BlackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlackController>(
      () => BlackController(),
    );
  }
}
