import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../controllers/black_controller.dart';

class BlackView extends GetView<BlackController> {
  @override
  Widget build(BuildContext context) {
    ScreenBrightness().setScreenBrightness(0.01);
    return Scaffold(body: InkWell(
      onTap: () {
        Get.back();
      },
    ));
  }
}
