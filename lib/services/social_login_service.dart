import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:readbox/config/google_signin_config.dart';
import 'dart:io';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';

class SocialLoginService {
  static final GoogleSignIn _googleSignIn = GoogleSignInConfig.googleSignIn;

  /// Kiểm tra xem app có đang chạy trên simulator không
  static bool get isSimulator {
    return Platform.isIOS &&
        Platform.environment['SIMULATOR_DEVICE_NAME'] != null;
  }

  /// Kiểm tra Google Play Services có sẵn không
  static Future<bool> isGooglePlayServicesAvailable() async {
    try {
      await _googleSignIn.isSignedIn();
      return true;
    } catch (e) {
      print('Google Play Services not available: $e');
      return false;
    }
  }

  /// Đăng nhập bằng Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Kiểm tra Google Play Services availability
      try {
        final bool isAvailable = await _googleSignIn.isSignedIn();
        print('Google Sign-In isSignedIn: $isAvailable');
      } catch (e) {
        print('⚠️ Google Play Services check failed: $e');
      }

      // Thử sign out trước để clear session
      try {
        await _googleSignIn.signOut();
        print('Signed out successfully');
      } catch (e) {
        print('⚠️ Sign out failed (may be normal): $e');
      }

      // Thử sign in với timeout
      print('Attempting to sign in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                AppLocalizations.current.google_play_services_not_available,
              );
            },
          );

      print('Google Sign-In result: ${googleUser?.email}');

      if (googleUser == null) {
        throw Exception(AppLocalizations.current.user_cancelled_google_sign_in);
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      return {
        'platformId': googleUser.id,
        'email': googleUser.email,
        'fullName': googleUser.displayName ?? '',
        'picture': googleUser.photoUrl,
        'platform': 'google',
        'accessToken': googleAuth.accessToken,
      };
    } catch (error) {
      // Log chi tiết lỗi để debug
      print('❌ Google Sign-In Error: $error');
      print('❌ Error type: ${error.runtimeType}');
      
      // Xử lý ApiException 8 (INTERNAL_ERROR)
      if (error.toString().contains('8:') || 
          error.toString().contains('INTERNAL_ERROR') ||
          error.toString().contains('ApiException: 8')) {
        print('⚠️ INTERNAL_ERROR (8) - Có thể do:');
        print('   1. Google Play Services chưa được cập nhật');
        print('   2. SHA-1 fingerprint chưa được thêm vào Google Cloud Console');
        print('   3. Package name không khớp: com.hungvv.readbox');
        print('   4. google-services.json chưa đúng hoặc chưa được sync');
        print('   5. Google Sign-In API chưa được enable');
        throw Exception(AppLocalizations.current.google_signin_failed);
      }
      
      // Xử lý ApiException 12500 (DEVELOPER_ERROR)
      if (error.toString().contains('12500') || 
          error.toString().contains('DEVELOPER_ERROR') ||
          error.toString().contains('developer_error')) {
        print('⚠️ DEVELOPER_ERROR (12500) - Cấu hình OAuth không đúng');
        throw Exception(AppLocalizations.current.google_developer_error);
      }
      
      // Xử lý các loại lỗi khác
      if (error.toString().contains('sign_in_failed')) {
        throw Exception(AppLocalizations.current.google_signin_failed);
      } else if (error.toString().contains('network_error') ||
          error.toString().contains('SocketException') ||
          error.toString().contains('Network is unreachable')) {
        throw Exception(AppLocalizations.current.google_network_error);
      } else if (error.toString().contains('invalid_client') ||
          error.toString().contains('10:')) {
        throw Exception(AppLocalizations.current.google_invalid_client);
      } else if (error.toString().contains('timeout')) {
        throw Exception(AppLocalizations.current.google_timeout);
      } else if (error.toString().contains('SERVICE_DISABLED') ||
          error.toString().contains('SERVICE_MISSING') ||
          error.toString().contains('SERVICE_VERSION_UPDATE_REQUIRED')) {
        throw Exception(
          AppLocalizations.current.google_play_services_not_available,
        );
      }

      // Re-throw với message chi tiết
      throw Exception('Google Sign-In Error: $error');
    }
  }

  /// Đăng nhập bằng Facebook
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      print('Running on platform: ${Platform.operatingSystem}');
      print('Running on simulator: $isSimulator');

      // Cảnh báo nếu đang chạy trên simulator
      if (isSimulator) {
        print('⚠️ WARNING: Running on iOS Simulator');
      }

      // Chỉ yêu cầu App Tracking Transparency trên iOS 14+
      // Android không hỗ trợ và sẽ trả về notSupported
      if (Platform.isIOS) {
        print('📱 iOS detected - Requesting tracking authorization...');
        final status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        print('📱 Tracking status: $status');
        
        // Trên iOS, nếu user từ chối tracking, vẫn cho phép đăng nhập
        // nhưng có thể hạn chế một số tính năng analytics
        if (status == TrackingStatus.denied || status == TrackingStatus.restricted) {
          print('⚠️ User denied tracking, but login will continue');
        }
      } else {
        print('🤖 Android detected - Skipping App Tracking Transparency');
      }

      // Thực hiện đăng nhập Facebook
      print('🔐 Starting Facebook login...');
      final LoginResult result = await FacebookAuth.instance.login(
      );

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        // Debug token chi tiết
        final accessToken = result.accessToken?.tokenString;

        if (accessToken == null) {
          throw Exception(AppLocalizations.current.facebook_access_token_is_null);
        }

        print('✅ Facebook login successful: ${userData['email']}');
        return {
          'platformId': userData['id'],
          'email': userData['email'] ?? '',
          'fullName': userData['name'] ?? '',
          'picture': userData['picture']?['data']?['url'],
          'platform': 'facebook',
          'accessToken': accessToken,
        };
      } else {
        print('❌ Facebook login failed with status: ${result.status}');
        throw Exception(AppLocalizations.current.facebook_login_failed);
      }
    } catch (error) {
      // Xử lý lỗi AX Lookup cụ thể cho iOS Simulator
      if (error.toString().contains('AX Lookup problem') ||
          error.toString().contains('Permission denied portName') ||
          error.toString().contains('com.apple.iphone.axserver')) {
        throw Exception(AppLocalizations.current.facebook_login_failed);
      } else if (error.toString().contains('network_error') ||
          error.toString().contains('SocketException') ||
          error.toString().contains('Network is unreachable')) {
        throw Exception(AppLocalizations.current.facebook_network_error);
      } else if (error.toString().contains('invalid_client') ||
          error.toString().contains('FacebookAppID')) {
        throw Exception(AppLocalizations.current.facebook_invalid_client);
      }

      rethrow;
    }
  }

  /// Đăng xuất Google
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Đăng xuất Facebook
  static Future<void> signOutFacebook() async {
    await FacebookAuth.instance.logOut();
  }

  /// Đăng xuất tất cả social accounts
  static Future<void> signOutAll() async {
    await Future.wait([signOutGoogle(), signOutFacebook()]);
  }
}
