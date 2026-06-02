import 'dart:io';

import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Test ID Android
      } else {
        return 'ca-app-pub-3618888231032837/3227095458'; // Real ID Android
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/2934735716'; // Test ID iOS
      } else {
        return 'ca-app-pub-3618888231032837/5440450977'; // Real ID iOS
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/1033173712'; // Test ID Android
      } else {
        return 'ca-app-pub-3618888231032837/2344577409'; // Real ID Android
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/4411468910'; // Test ID iOS
      } else {
        return 'ca-app-pub-3618888231032837/9282503381'; // Real ID iOS
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/5224354917'; // Test ID Android
      } else {
        return 'ca-app-pub-3618888231032837/2411191867'; // Real ID Android (placeholder, should be replaced by user)
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return 'ca-app-pub-3940256099942544/1712485313'; // Test ID iOS
      } else {
        return 'ca-app-pub-3618888231032837/1309634271'; // Real ID iOS (placeholder, should be replaced by user)
      }
    }
    throw UnsupportedError('Unsupported platform');
  }
}
