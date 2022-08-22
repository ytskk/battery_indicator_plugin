import Flutter
import UIKit


public class SwiftBatteryIndicatorPlugin: NSObject, FlutterPlugin {
    let generator = BatteryInfoGenerator()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftBatteryIndicatorPlugin()
        
        let channel = FlutterMethodChannel(name: "battery_indicator/channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "battery_indicator/stream", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(SwiftStreamHandler())
    }


    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let batteryInfo = generator.generate()
        
        if batteryInfo < 0 {
            result(nil)
        }

        result(batteryInfo)
    }
}

class SwiftStreamHandler: NSObject, FlutterStreamHandler {
    let generator = BatteryInfoGenerator()
    var eventSink: FlutterEventSink?

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        let batteryInfo = generator.generate()

        if (batteryInfo < 0) {
            eventSink(nil)
            return nil
        }


        eventSink(batteryInfo)
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

struct BatteryInfoGenerator {
    let device: UIDevice

    init() {
        device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
    }


    private func getBatteryLevel() -> Int {
        Int(device.batteryLevel * 100)
    }


    func generate() -> Int {
        let batteryInfo = getBatteryLevel()
        return batteryInfo
    }
}
