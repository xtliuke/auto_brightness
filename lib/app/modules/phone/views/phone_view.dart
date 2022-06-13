import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../controllers/phone_controller.dart';

class PhoneView extends GetView<PhoneController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text(
                "光线值：${controller.sensorValue}",
                style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Get.defaultDialog(
                      title: "使用说明",
                      content: const Text("请保持手机屏幕常亮\n"
                          "不要锁屏\n"
                          "\n"
                          "可以选择时钟模式或纯黑模式节省电量\n"
                          "\n"
                          "WIFI模式(默认，无需选择)：\n"
                          " - 打开电脑端软件\n"
                          " - 请打开手机WIFI\n"
                          " - 将手机连接到与电脑同网段的网络上\n"
                          "\n"
                          "USB模式(PC软件勾选即可)：\n"
                          " - 打开电脑端软件并打开USB模式\n"
                          " - 请打开手机USB调试模式\n"
                          " - 使用数据线将手机连接上电脑"));
                },
                child: const Text("使用说明")),
            ElevatedButton(
                onPressed: () async {
                  await Get.toNamed("clock");
                  ScreenBrightness().setScreenBrightness(0.2);
                },
                child: const Text("时钟模式")),
            ElevatedButton(
                onPressed: () async {
                  await Get.toNamed("black");
                  ScreenBrightness().setScreenBrightness(0.2);
                },
                child: const Text("纯黑模式")),
          ],
        ),
      ),
    );
  }
}
