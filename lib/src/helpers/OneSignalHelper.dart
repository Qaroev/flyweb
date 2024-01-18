import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
class OneSignalHelper with ChangeNotifier {
  String? url;
  OneSignalHelper() {
    /*OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      if (result.notification.additionalData != null &&
          result.notification.additionalData!['url'] != null) {
        url = result.notification.additionalData!['url'];
        notifyListeners();
      }
    });
    */

    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.Debug.setLogLevel(OSLogLevel.none);
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent result) {
      if (result.notification.additionalData != null &&
          result.notification.additionalData!['url'] != null) {
        url = result.notification.additionalData!['url'];
        notifyListeners();
      }
    });
  }
}

