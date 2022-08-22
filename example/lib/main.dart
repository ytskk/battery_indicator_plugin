import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:battery_indicator/battery_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _batteryLevel = -1;
  final _batteryIndicatorPlugin = BatteryIndicator();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    int batteryLevel;
    try {
      batteryLevel = await _batteryIndicatorPlugin.getBatteryInfo() ?? -1;
      print('batteryLevel: $batteryLevel');
    } on PlatformException catch (e) {
      print('error: ${e}');
      batteryLevel = -1;
    }

    if (!mounted) return;

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_batteryLevel);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),

        /// Returns a future that resolves to the battery level.
        // body: Center(
        //   child: _BatteryIndicator(
        //     batteryLevel: _batteryLevel,
        //   ),
        // ),

        /// Returns a stream of battery level updates.
        body: StreamBuilder<int?>(
          stream: _batteryIndicatorPlugin.getBatteryInfoStream(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return Center(
              child: _BatteryIndicator(
                batteryLevel: snapshot.data ?? 1,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  const _BatteryIndicator({
    Key? key,
    required this.batteryLevel,
  }) : super(key: key);

  final int batteryLevel;
  final double maxWidth = 400;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final widgetWidth = width.clamp(100, maxWidth) / 2;
    print('width: $width, widgetWidth: $widgetWidth');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Container(
            width: widgetWidth,
            height: widgetWidth * 2,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widgetWidth * 0.225),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: widgetWidth * 2 * (batteryLevel / 100),
                color: Colors.black12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$batteryLevel%',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
      ],
    );
  }
}
