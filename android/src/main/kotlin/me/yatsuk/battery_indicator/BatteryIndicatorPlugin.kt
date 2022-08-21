package me.yatsuk.battery_indicator

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** BatteryIndicatorPlugin */
class BatteryIndicatorPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var applicationContext: Context
    private lateinit var batteryStatusReceiver: BroadcastReceiver

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "battery_indicator/channel")
        channel.setMethodCallHandler(this)
        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "battery_indicator/stream")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getBatteryInfo" -> {
                result.success(getBatteryInfo())
            }
            else -> {
                result.success("haha")
//                result.notImplemented()
            }
        }
    }

    private fun getBatteryInfo(): Int {
        var batteryLevel: Int = -1

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryLevel =
                (applicationContext.getSystemService(Context.BATTERY_SERVICE) as BatteryManager).getIntProperty(
                    BatteryManager.BATTERY_PROPERTY_CAPACITY
                )
        }

        return batteryLevel
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        batteryStatusReceiver = batteryStatusChangeReceiver(events)
        applicationContext.registerReceiver(
            batteryStatusReceiver,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
    }

    override fun onCancel(arguments: Any?) {
        applicationContext.unregisterReceiver(batteryStatusReceiver)
    }

    private fun batteryStatusChangeReceiver(events: EventChannel.EventSink?): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                events?.success(getBatteryInfo())
            }
        }
    }
}
