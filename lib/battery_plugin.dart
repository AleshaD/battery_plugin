import 'dart:async';

import 'battery_plugin_platform_interface.dart';

enum BatteryLevel {
  low,
  okay,
}

class BatteryPlugin {
  static final instance = BatteryPlugin();

  Future<String?> getPlatformVersion() {
    return BatteryPluginPlatform.instance.getPlatformVersion();
  }

  Future<int?> getCurrentBatteyLvl() {
    return BatteryPluginPlatform.instance.getCurrentBatteryLvl();
  }

  Stream<String> get batteryChanged =>
      BatteryPluginPlatform.instance.batteryChanged;
}
