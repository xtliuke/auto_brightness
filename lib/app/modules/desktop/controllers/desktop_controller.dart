import 'dart:async';

import 'package:get/get.dart';
import 'package:udp/udp.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class DesktopController extends GetxController {
  final sensorValue = 0.obs;
  final maxSensorValue = 300.obs;

  final brightness = 0.obs;
  final maxBrightness = 100.obs;

  static final monitors = <int>[];
  final physicalMonitorHandles = <int>[];
  static int nextBrightness = 0;

  Future<void> startService() async {
    var socket = await UDP.bind(Endpoint.any(port: const Port(8888)));
    socket.asStream().listen((event) {
      sensorValue.value = int.parse(String.fromCharCodes(event!.data));
      brightness.value = (sensorValue.value / maxSensorValue.value * maxBrightness.value).toInt();
      brightness.value = brightness.value > maxBrightness.value ? maxBrightness.value : brightness.value;
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
