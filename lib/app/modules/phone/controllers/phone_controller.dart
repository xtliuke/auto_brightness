import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:get/get.dart';
import 'package:light/light.dart';
import 'package:udp/udp.dart';
import 'dart:io';
import 'package:wakelock/wakelock.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneController extends GetxController {
  final sensorValue = 0.obs;

  final ipController = TextEditingController();
  var currentIP = "";

  Future<void> initParas() async {
    FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    Wakelock.enable();
    Timer(const Duration(seconds: 10), () {
      ScreenBrightness().setScreenBrightness(0.2);
    });
    final prefs = await SharedPreferences.getInstance();
    currentIP = prefs.getString('ip')!;
    ipController.text = currentIP;
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
    if (currentIP.isEmpty) {
      socket.send("$sensorValue".codeUnits, Endpoint.broadcast(port: const Port(8888)));
    } else {
      socket.send("$sensorValue".codeUnits, Endpoint.multicast(InternetAddress(currentIP), port: const Port(8888)));
    }

    dio.post("http://127.0.0.1:9999", data: "$sensorValue");
  }

  Future<bool> saveIp() async {
    String ip = ipController.text;
    if (ip.isEmpty ||
        RegExp("^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\."
                "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
                "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\$")
            .hasMatch(ip)) {
      currentIP = ip;
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('ip', ip);
      return true;
    } else {
      return false;
    }
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
