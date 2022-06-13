import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../controllers/clock_controller.dart';
import 'package:analog_clock/analog_clock.dart';

class ClockView extends GetView<ClockController> {
  @override
  Widget build(BuildContext context) {
    ScreenBrightness().setScreenBrightness(0.1);
    return Scaffold(
      body: InkWell(
        onTap: () {
          Get.back();
        },
        child: Container(
          color: Colors.black,
          child: const AnalogClock(
            hourHandColor: Colors.white54,
            minuteHandColor: Colors.white54,
            secondHandColor: Colors.red,
            numberColor: Colors.white54,
            digitalClockColor: Colors.white54,
          ),
        ),
      ),
    );
  }
}
