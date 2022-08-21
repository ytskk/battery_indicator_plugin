import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'battery_indicator_platform_interface.dart';

/// An implementation of [BatteryIndicatorPlatform] that uses method channels.
class MethodChannelBatteryIndicator extends BatteryIndicatorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('battery_indicator/channel');
  final eventChannel = const EventChannel('battery_indicator/stream');

  @override
  Future<int?> getBatteryInfo() async {
    final int? batteryInfo =
        await methodChannel.invokeMethod<int>('getBatteryInfo');
    return batteryInfo;
  }

  @override
  Stream<int?> getBatteryInfoStream() {
    return eventChannel
        .receiveBroadcastStream()
        .map<int?>((dynamic event) => event as int?);
  }

  Stream<int?> onBatteryPowerChanged(double value) {
    return eventChannel
        .receiveBroadcastStream()
        .map<int?>((dynamic event) => event as int?);
  }
}
