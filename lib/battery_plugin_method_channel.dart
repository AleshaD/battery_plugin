import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'battery_plugin_platform_interface.dart';

const String _batteryStateChanges = 'battery_state_changes';
const String _getCurrentBatteryLvl = 'get_current_battery_lvl';

/// An implementation of [BatteryPluginPlatform] that uses method channels.
class MethodChannelBatteryPlugin extends BatteryPluginPlatform {
  MethodChannelBatteryPlugin() {
    _initChannels();
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> getCurrentBatteryLvl() async {
    final lvl = await methodChannel.invokeMethod<int>(_getCurrentBatteryLvl);
    return lvl;
  }

  @override
  Stream<String> get batteryChanged => _batteryStreamController.stream;

  final StreamController<String> _batteryStreamController =
      StreamController.broadcast();

  void _initChannels() {
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case _batteryStateChanges:
          _batteryStreamController.sink.add(call.arguments as String);
          break;
        default:
      }
    });
  }
}
