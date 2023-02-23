import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:battery_plugin/battery_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: const BatteryPluginExample(),
      ),
    );
  }
}

class BatteryPluginExample extends StatefulWidget {
  const BatteryPluginExample({Key? key}) : super(key: key);

  @override
  _BatteryPluginExampleState createState() => _BatteryPluginExampleState();
}

class _BatteryPluginExampleState extends State<BatteryPluginExample> {
  int? _batteryLvl;
  final _batteryPlugin = BatteryPlugin.instance;
  late final StreamSubscription _lvlChangesubscription;

  @override
  void initState() {
    super.initState();
    _lvlChangesubscription = BatteryPlugin.instance.batteryChanged
        .listen(_showSnackBarAndUpdateBatLvl);
    _updateCurrentBatLvl();
  }

  @override
  void dispose() {
    _lvlChangesubscription.cancel();
    super.dispose();
  }

  void _showSnackBarAndUpdateBatLvl(String val) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(val),
      ),
    );
  }

  Future<void> _updateCurrentBatLvl() async {
    try {
      final lvl = await _batteryPlugin.getCurrentBatteyLvl();
      setState(() {
        _batteryLvl = lvl;
      });
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to get platform version.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('Current Battery Lvl: $_batteryLvl\n'),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _updateCurrentBatLvl,
              child: const Text('Update Battery Lvl'),
            ),
          )
        ],
      ),
    );
  }
}
