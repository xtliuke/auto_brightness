import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:get/get.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:udp/udp.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:process_run/shell.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DesktopController extends GetxController {
  final sensorValue = 0.obs;
  final maxSensorValue = 300.obs;
  final minSensorValue = 0.obs;

  final brightness = 0.obs;
  final maxBrightness = 100.obs;
  final minBrightness = 0.obs;

  static final monitors = <int>[];
  final physicalMonitorHandles = <int>[];
  static int nextBrightness = 0;

  final isAutoStart = false.obs;

  Future<void> startService() async {
    var socket = await UDP.bind(Endpoint.any(port: const Port(8888)));
    socket.asStream().listen((event) {
      sensorValue.value = int.parse(String.fromCharCodes(event!.data));
      var mSensorValue = sensorValue.value;
      if (mSensorValue > maxSensorValue.value) mSensorValue = maxSensorValue.value;
      if (mSensorValue < minSensorValue.value) mSensorValue = minSensorValue.value;
      var mBrightness = ((mSensorValue / maxSensorValue.value) * maxBrightness.value).toInt();
      if (mBrightness > maxBrightness.value) mBrightness = maxBrightness.value;
      if (mBrightness < minBrightness.value) mBrightness = minBrightness.value;
      brightness.value = mBrightness;
    });
    initMonitors();
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      refreshBrightness();
    });
  }

  static int enumMonitorCallback(int hMonitor, int hDC, Pointer lpRect, int lParam) {
    monitors.add(hMonitor);
    return TRUE;
  }

  void initMonitors() {
    monitors.clear();
    physicalMonitorHandles.clear();
    var result = FALSE;
    result = EnumDisplayMonitors(NULL, nullptr, Pointer.fromFunction<MonitorEnumProc>(enumMonitorCallback, 0), NULL);
    if (result == FALSE) return;
    for (var monitor in monitors) {
      final physicalMonitorCountPtr = calloc<DWORD>();
      result = GetNumberOfPhysicalMonitorsFromHMONITOR(monitor, physicalMonitorCountPtr);
      if (result == FALSE) return;
      final physicalMonitorArray = calloc<PHYSICAL_MONITOR>(physicalMonitorCountPtr.value);
      result = GetPhysicalMonitorsFromHMONITOR(monitor, physicalMonitorCountPtr.value, physicalMonitorArray);
      if (result == FALSE) return;
      physicalMonitorHandles.add(physicalMonitorArray.cast<IntPtr>().value);
    }
    if (physicalMonitorHandles.isEmpty) return;
    final minimumBrightnessPtr = calloc<DWORD>();
    final currentBrightnessPtr = calloc<DWORD>();
    final maximumBrightnessPtr = calloc<DWORD>();
    result = GetMonitorBrightness(physicalMonitorHandles[0], minimumBrightnessPtr, currentBrightnessPtr, maximumBrightnessPtr);
    if (result == FALSE) return;
    nextBrightness = currentBrightnessPtr.value;
    brightness.value = currentBrightnessPtr.value;
  }

  void refreshBrightness() {
    if (nextBrightness > brightness.value) {
      nextBrightness = nextBrightness - 1;
      for (var handle in physicalMonitorHandles) {
        SetMonitorBrightness(handle, nextBrightness);
      }
    } else if (nextBrightness < brightness.value) {
      nextBrightness = nextBrightness + 1;
      for (var handle in physicalMonitorHandles) {
        SetMonitorBrightness(handle, nextBrightness);
      }
    }
  }

  Future<void> setupTray() async {
    await trayManager.setIcon('assets/images/icon-35x35.ico');
    await trayManager.setContextMenu(Menu(items: [
      MenuItem(
        key: 'show_window',
        label: '显示主界面',
      ),
      MenuItem(
        key: 'exit_app',
        label: '退出',
      ),
    ]));
    trayManager.addListener(_MyTrayListener());
  }

  Future<void> setupUsbMode() async {
    var shell = Shell();
    await shell.run("adb forward --remove-all");
    await shell.run("adb forward tcp:6666 tcp:6666");
  }

  Future<void> setupStartUp(bool enable) async {
    WidgetsFlutterBinding.ensureInitialized();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
    );

    if (enable) {
      await launchAtStartup.enable();
      isAutoStart.value = true;
    } else {
      await launchAtStartup.disable();
      isAutoStart.value = false;
    }
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

class _MyTrayListener extends TrayListener {
  @override
  void onTrayIconMouseDown() {
    appWindow.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      appWindow.show();
    } else if (menuItem.key == 'exit_app') {
      appWindow.close();
    }
  }
}
