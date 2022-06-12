import 'dart:async';
import 'dart:io';

import 'package:belatuk_http_server/belatuk_http_server.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart' hide MenuItem;
import 'package:get/get.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final isUsbMode = false.obs;

  Future<void> startUdpService() async {
    var socket = await UDP.bind(Endpoint.any(port: const Port(8888)));
    socket.asStream().listen((event) {
      sensorValue.value = int.parse(String.fromCharCodes(event!.data));
    });
  }

  Future<void> startHttpService() async {
    var server = await HttpServer.bind('0.0.0.0', 9999);
    server.transform(HttpBodyHandler()).listen((body) {
      sensorValue.value = int.parse(body.body.toString());
      body.request.response.close();
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
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      refreshBrightness();
    });
  }

  void refreshBrightness() {
    var mSensorValue = sensorValue.value;
    if (mSensorValue > maxSensorValue.value) mSensorValue = maxSensorValue.value;
    if (mSensorValue < minSensorValue.value) mSensorValue = minSensorValue.value;
    var mBrightness = ((mSensorValue / maxSensorValue.value) * maxBrightness.value).toInt();
    if (mBrightness > maxBrightness.value) mBrightness = maxBrightness.value;
    if (mBrightness < minBrightness.value) mBrightness = minBrightness.value;
    if (mBrightness == 0) return;
    brightness.value = mBrightness;
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

  Future<void> initUsbMode() async {
    var shell = Shell();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (isUsbMode.value) {
        await shell.run("adb reverse tcp:9999 tcp:9999");
      }
    });
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
    } else {
      await launchAtStartup.disable();
    }
  }

  Future<void> initParas() async {
    final prefs = await SharedPreferences.getInstance();
    minBrightness.value = prefs.getInt("minBrightness")!;
    maxBrightness.value = prefs.getInt("maxBrightness")!;
    minSensorValue.value = prefs.getInt("minSensorValue")!;
    maxSensorValue.value = prefs.getInt("maxSensorValue")!;
    isAutoStart.value = prefs.getBool("isAutoStart")!;
    isUsbMode.value = prefs.getBool("isUsbMode")!;
  }

  Future<void> saveParas() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("minBrightness", minBrightness.value);
    prefs.setInt("maxBrightness", maxBrightness.value);
    prefs.setInt("minSensorValue", minSensorValue.value);
    prefs.setInt("maxSensorValue", maxSensorValue.value);
    prefs.setBool("isAutoStart", isAutoStart.value);
    prefs.setBool("isUsbMode", isUsbMode.value);
  }

  @override
  void onInit() {
    setupTray();
    initParas();
    initMonitors();
    startUdpService();
    startHttpService();
    initUsbMode();
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
