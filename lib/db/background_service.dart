import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initiazizeService() async {
  print("Initializing service...");
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        autoStart: true,
        onBackground: onIosBackgroundService,
      ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart, isForegroundMode: true, autoStart: true));
  print("Service initialized...");
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen(
      (event) {
        service.setAsForegroundService();
      },
    );
    service.on('setAsBackground').listen(
      (event) {
        service.setAsBackgroundService();
      },
    );
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  Timer.periodic(
    const Duration(seconds: 5),
    (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
              title: "tesigin", content: "helppp");
        }
      }

      print("backgroung task running... ");
      service.invoke('update');
    },
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackgroundService(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
