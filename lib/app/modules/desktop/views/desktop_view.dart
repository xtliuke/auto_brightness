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
          Container(
            padding: const EdgeInsets.all(25),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShowBrightness(),
                  _buildShowSensor(),
                  _buildControlBrightness(),
                  _buildControlSensor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
              "环境光范围控制：${controller.minSensorValue}-${controller.maxSensorValue}",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
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
              "显示器亮度范围控制：${controller.minBrightness}-${controller.maxBrightness}",
              style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
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

  Widget _buildShowSensor() {
    return Obx(
      () => Text(
        "光线值：${controller.sensorValue}",
        style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
      ),
    );
  }

  Widget _buildShowBrightness() {
    return Obx(
      () => Text(
        "亮度值：${controller.brightness}",
        style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
      ),
    );
  }
}
