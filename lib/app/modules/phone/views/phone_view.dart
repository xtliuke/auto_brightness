import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../controllers/phone_controller.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';

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
            _buildSensorValue(),
            _buildHowTo(),
            _buildClockMode(),
            _buildBlackMode(),
            _buildSetNetwork(),
            _buildAbout(),
          ],
        ),
      ),
    );
  }

  Widget _buildSetNetwork() {
    return ElevatedButton(
        onPressed: () async {
          Get.defaultDialog(
            title: "网络设置",
            content: Column(
              children: [
                const Text("请填写正确的IP地址\n"
                    "什么都不填点保存就是恢复默认值"),
                TextField(
                  decoration: const InputDecoration(labelText: "IP地址", hintText: "例：192.168.1.100，或什么都不填"),
                  controller: controller.ipController,
                ),
              ],
            ),
            textConfirm: "保存",
            textCancel: "取消",
            onConfirm: () async {
              if (await controller.saveIp()) {
                Get.back();
                showToast("保存成功");
              } else {
                showToast("保存失败，请检查IP地址是否正确");
              }
            },
            onCancel: () => Get.back(),
          );
        },
        child: const Text("网络设置"));
  }

  Widget _buildBlackMode() {
    return ElevatedButton(
        onPressed: () async {
          await Get.toNamed("black");
          ScreenBrightness().setScreenBrightness(0.2);
        },
        child: const Text("纯黑模式"));
  }

  Widget _buildClockMode() {
    return ElevatedButton(
        onPressed: () async {
          await Get.toNamed("clock");
          ScreenBrightness().setScreenBrightness(0.2);
        },
        child: const Text("时钟模式"));
  }

  Widget _buildHowTo() {
    return ElevatedButton(
        onPressed: () {
          Get.defaultDialog(
            title: "使用说明",
            content: const Text("请保持手机屏幕常亮\n"
                "不要锁屏\n"
                "\n"
                "可以选择时钟模式或纯黑模式节省电量\n"
                "\n"
                "通过WIFI通信(默认，无需选择)：\n"
                " - 打开电脑端软件\n"
                " - 打开手机WIFI\n"
                " - 将手机连接到与电脑同网段的网络上\n"
                " - 打开手机端APP（本应用）即可\n"
                " - 如果遇到无法连接的情况\n"
                " - 可以通过“网络设置”修改IP地址\n"
                "\n"
                "通过USB通信(PC软件勾选即可)：\n"
                " - 打开电脑端软件并打开USB模式\n"
                " - 打开手机USB调试模式\n"
                " - 使用数据线将手机连接上电脑"),
            textConfirm: "好的",
            onConfirm: () => Get.back(),
          );
        },
        child: const Text("使用说明"));
  }

  Widget _buildSensorValue() {
    return Obx(
      () => Text(
        "光线值：${controller.sensorValue}",
        style: const TextStyle(color: Colors.blueAccent, fontSize: 25),
      ),
    );
  }

  Widget _buildAbout() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          const Divider(),
          const Text("本软件的使用完全免费"),
          const Text("如果喜欢，请在 bilibili 关注我，谢谢！"),
          ElevatedButton(
            onPressed: () async {
              await launchUrl(Uri.parse("https://space.bilibili.com/5057929"));
            },
            child: const Text("点击访问：萝卜北的杂货铺"),
          ),
        ],
      ),
    );
  }
}
