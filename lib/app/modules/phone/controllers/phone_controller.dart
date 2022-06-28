import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:get/get.dart';
import 'package:light/light.dart';
import 'package:udp/udp.dart';
import 'dart:io';
import 'package:wakelock/wakelock.dart';
import 'package:screen_brightness/screen_brightness.dart';

class PhoneController extends GetxController {
  final sensorValue = 0.obs;

  void initParas() {
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    Wakelock.enable();
    Timer(const Duration(seconds: 10), () {
      ScreenBrightness().setScreenBrightness(0.2);
    });
  }

  Future<void> startLightService() async {
    Light().lightSensorStream.listen((event) {
      if ((sensorValue.value - event).abs() > 5) {
        sensorValue.value = event;
        sendMsg();
      }
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      sendMsg();
    });
  }

  Future<void> sendMsg() async {
    var socket = await UDP.bind(Endpoint.any(port: const Port(8888)));
    var dio = Dio();
    socket.send("$sensorValue".codeUnits, Endpoint.broadcast(port: const Port(8888)));
    dio.post("http://127.0.0.1:9999", data: "$sensorValue");
  }

  @override
  void onInit() {
    initParas();
    startLightService();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
