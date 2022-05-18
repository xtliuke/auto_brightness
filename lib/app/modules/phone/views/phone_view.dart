import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/phone_controller.dart';

class PhoneView extends GetView<PhoneController> {
  @override
  Widget build(BuildContext context) {
    controller.startService();

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("请打开手机WIFI"),
            const Text("将手机连接到与电脑同网段的网络上"),
            const Text("请保持手机屏幕常亮"),
            const Text("不要锁屏"),
            const Text("为了节省手机电量"),
            const Text("我们稍后会调低手机屏幕亮度"),
            Obx(
              () => Text(
                "光线值：${controller.sensorValue}",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
