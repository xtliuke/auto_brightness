import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/error_controller.dart';

class ErrorView extends GetView<ErrorController> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '暂不支持',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
