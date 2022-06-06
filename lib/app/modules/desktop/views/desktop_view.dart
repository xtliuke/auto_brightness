import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_seekbar/flutter_advanced_seekbar.dart';

import 'package:get/get.dart';

import '../controllers/desktop_controller.dart';

class DesktopView extends GetView<DesktopController> {
  @override
  Widget build(BuildContext context) {
    controller.startService();
    controller.setupTray();
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
                MinimizeWindowButton(),
                CloseWindowButton(
                  onPressed: () {
                    appWindow.hide();
                  },
                ),
              ],
            ),
          ),
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

  Widget _buildControlSensor() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            "环境光控制（最大光线值）：${controller.maxSensorValue}",
            style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
        ),
        AdvancedSeekBar(
          Colors.white30,
          15,
          Colors.blue,
          lineHeight: 5,
          defaultProgress: 30,
          scaleWhileDrag: true,
          seekBarProgress: (v) {
            controller.maxSensorValue.value = v * 10;
          },
        ),
      ],
    );
  }

  Widget _buildControlBrightness() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            "亮度控制（最大亮度）：${controller.maxBrightness}",
            style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
          ),
        ),
        AdvancedSeekBar(
          Colors.white30,
          15,
          Colors.blue,
          lineHeight: 5,
          defaultProgress: 100,
          scaleWhileDrag: true,
          seekBarProgress: (v) {
            controller.maxBrightness.value = v;
          },
        ),
      ],
    );
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
