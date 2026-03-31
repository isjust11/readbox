

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
      final apiKey = dotenv.env['REVENUECAT_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) {
          print('RevenueCat API Key is missing in .env');
        }
        return;
      }

      await Purchases.setLogLevel(LogLevel.debug);

      // Initialize RevenueCat configuration
      PurchasesConfiguration configuration;
      
      // Usually you differentiate between iOS and Android. 
      // If you use the same key for both, just pass it.
      // If you only plan to fix this on iOS first, it will configure for iOS when running iOS.
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
}
