package com.example.sha.battery_plugin

import android.content.BroadcastReceiver
import android.content.ContentResolver
import android.content.Context.BATTERY_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BatteryPlugin */
class BatteryPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel : MethodChannel

  private lateinit var binding: ActivityPluginBinding
  private lateinit var contentResolver: ContentResolver

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "battery_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "get_current_battery_lvl") {
        channel.invokeMethod("battery_state_changes", "Called Battery Level")
        val lvl = getCurrentBatteryLvl()
      result.success(lvl)
    } else {
      result.notImplemented()
    }
  }

  fun getCurrentBatteryLvl(): Int {
    val bm = binding.activity.applicationContext.getSystemService(BATTERY_SERVICE) as BatteryManager

    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      return 0
    }
  }

private fun subscribeToBatteryStateChanges() {

    val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
      binding.activity.applicationContext.registerReceiver(null, ifilter)
    }

    val status: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
    val isCharging: Boolean = status == BatteryManager.BATTERY_STATUS_CHARGING
            || status == BatteryManager.BATTERY_STATUS_FULL

  // How are we charging?
    val chargePlug: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
    val usbCharge: Boolean = chargePlug == BatteryManager.BATTERY_PLUGGED_USB
    val acCharge: Boolean = chargePlug == BatteryManager.BATTERY_PLUGGED_AC

    val result: String
    result = if (isCharging) {
      "Charging"
    } else {
      "Not Changing"
    }

    channel.invokeMethod("battery_state_changes", result)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding
    this.contentResolver = binding.activity.contentResolver
    subscribeToBatteryStateChanges()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }
}
