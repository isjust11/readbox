import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();

  factory RevenueCatService() {
    return _instance;
  }

  RevenueCatService._internal();

  static RevenueCatService get instance => _instance;

  Future<void> init() async {
    try {
      final apiKey =
          Platform.isIOS
              ? dotenv.env['REVENUECAT_IOS_KEY']
              : dotenv.env['REVENUECAT_ANDROID_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) {
          print(
            'RevenueCat API Key is missing in .env for ${Platform.operatingSystem}',
          );
        }
        return;
      }

      await Purchases.setLogLevel(LogLevel.debug);

      // Initialize RevenueCat configuration
      PurchasesConfiguration configuration;

      configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);

      if (kDebugMode) {
        print('RevenueCat initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing RevenueCat: $e');
      }
    }
  }

  Future<void> login(String appUserId) async {
    try {
      await Purchases.logIn(appUserId);
      if (kDebugMode) {
        print('RevenueCat user logged in: $appUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging in to RevenueCat: $e');
      }
    }
  }

  Future<void> logout() async {
    try {
      await Purchases.logOut();
      if (kDebugMode) {
        print('RevenueCat user logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out of RevenueCat: $e');
      }
    }
  }

  Future<bool> checkSubscriptionStatus(String entitlementId) async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementId] != null &&
          customerInfo.entitlements.all[entitlementId]!.isActive) {
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking subscription status: $e');
      }
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      if (kDebugMode) {
        print('RevenueCat: Purchases restored');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error restoring purchases: $e');
      }
      rethrow;
    }
  }
}
