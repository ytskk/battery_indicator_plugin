import 'battery_indicator_platform_interface.dart';

class BatteryIndicator {
  Future<int?> getBatteryInfo() {
    return BatteryIndicatorPlatform.instance.getBatteryInfo();
  }

  Stream<int?> getBatteryInfoStream() {
    return BatteryIndicatorPlatform.instance.getBatteryInfoStream();
  }
}
