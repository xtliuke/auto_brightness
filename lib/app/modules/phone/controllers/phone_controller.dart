import 'dart:async';

import 'package:get/get.dart';
import 'package:light/light.dart';
import 'package:udp/udp.dart';
import 'dart:io';
import 'package:wakelock/wakelock.dart';
import 'package:screen_brightness/screen_brightness.dart';

class PhoneController extends GetxController {
  final sensorValue = 0.obs;

  Future<void> startService() async {
    Wakelock.enable();
    Timer(const Duration(seconds: 30), () {
      ScreenBrightness().setScreenBrightness(0.01);
    });
    var socket = await UDP.bind(Endpoint.any(port: const Port(8888)));

    Light().lightSensorStream.listen((event) {
      sensorValue.value = event;
      socket.send("$sensorValue".codeUnits, Endpoint.broadcast(port: const Port(8888)));
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      socket.send("$sensorValue".codeUnits, Endpoint.broadcast(port: const Port(8888)));
    });
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
