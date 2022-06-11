import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controllers/desktop_controller.dart';

class DesktopView extends GetView<DesktopController> {
  @override
  Widget build(BuildContext context) {
    controller.startService();
    controller.setupTray();
    return Scaffold(
      body: Column(
        children: [
          _buildTitleBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildControlBrightness(),
                      _buildControlSensor(),
                      _buildStartUpButton(),
                      _buildUseUsbButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUseUsbButton() {
    return Row(children: [
      const Text("使用USB连接手机", style: TextStyle(color: Colors.blueAccent, fontSize: 20)),
      const Spacer(),
      Switch(value: false, onChanged: (v) {})
    ]);
  }

  Widget _buildStartUpButton() {
    return Obx(() => Row(children: [
          const Text("开机自启动", style: TextStyle(color: Colors.blueAccent, fontSize: 20)),
          const Spacer(),
          Switch(
              value: controller.isAutoStart.value,
              onChanged: (v) {
                controller.setupStartUp(v);
              })
        ]));
  }

  Widget _buildTitleBar() {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(child: MoveWindow()),
          MinimizeWindowButton(colors: WindowButtonColors(iconNormal: Colors.white)),
          CloseWindowButton(
            colors: WindowButtonColors(iconNormal: Colors.white, mouseOver: Colors.red),
            onPressed: () {
              appWindow.hide();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlSensor() {
    return Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "环境光范围：${controller.minSensorValue}-${controller.maxSensorValue} [当前：${controller.sensorValue}]",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 20),
            ),
            SfRangeSlider(
              min: 0,
              max: 3000,
              stepSize: 1,
              values: SfRangeValues(controller.minSensorValue.value.toDouble(), controller.maxSensorValue.value.toDouble()),
              onChanged: (v) {
                controller.minSensorValue.value = v.start.round();
                controller.maxSensorValue.value = v.end.round();
              },
            ),
          ],
        ));
  }

  Widget _buildControlBrightness() {
    return Obx(() => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "显示器亮度范围：${controller.minBrightness}-${controller.maxBrightness} [当前：${controller.brightness}]",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 20),
            ),
            SfRangeSlider(
              min: 0,
              max: 100,
              stepSize: 1,
              values: SfRangeValues(controller.minBrightness.value.toDouble(), controller.maxBrightness.value.toDouble()),
              onChanged: (v) {
                controller.minBrightness.value = v.start.round();
                controller.maxBrightness.value = v.end.round();
              },
            ),
          ],
        ));
  }
}
