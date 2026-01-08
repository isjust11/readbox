import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/base_bloc/base.dart';
import 'package:readbox/blocs/utils.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/services/services.dart';
import 'package:readbox/utils/shared_preference.dart';

class AuthCubit extends Cubit<BaseState> {
  final AuthRepository repository;
  final SecureStorageService _secureStorage = SecureStorageService();

  AuthCubit({required this.repository}) : super(InitState());

  Future doLogin({String? username, String? password}) async {
    try {
      emit(LoadingState());
      AuthenModel userModel = await repository.login({
        "username": username,
        "password": password,
      });
      //save secure storage
      await BiometricAuthService.storeCredentials(username!, password!);

      // Gửi FCM token sau khi login thành công
      await _sendFCMTokenAfterLogin();
      // fcmRepository.registerFcmToken();

      emit(LoadedState(userModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Gửi FCM token lên server sau khi login thành công (đã có userId)
  Future<void> _sendFCMTokenAfterLogin() async {
    try {
      // final fcmService = FCMService(
      //   fcmRepository: getIt.getIt.get<FcmRepository>(),
      // );
      // // Gửi token lên server với userId (từ JWT token trong header)
      // await fcmService.sendTokenToServer();
    } catch (e) {
      // Không throw error để không ảnh hưởng đến flow login
      print('Error sending FCM token after login: $e');
    }
  }

  Future doLogout() async {
    try {
      emit(LoadingState());
      
      // Xóa tất cả dữ liệu nhạy cảm từ secure storage
      await _secureStorage.clearAllSecureData();
      
      // Xóa preferences (non-sensitive data)
      await SharedPreferenceUtil.clearData();
      
      emit(LoadedState(null));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future getProfile() async {
    try {
      emit(LoadingState());
      final profile = await repository.getProfile();
      emit(LoadedState(profile));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future doForgotPassword({String? username}) async {
    try {
      emit(LoadingState());
      // await repository.forgotPassword(userName);
      emit(LoadedState(null));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future doRegister({
    String? fullName,
    String? email,
    String? phone,
    String? username,
    String? password,
  }) async {
    try {
      emit(LoadingState());
      var result = await repository.register({
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "username": username,
        "password": password,
      });

      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future verifyPin({required String email, required String pin}) async {
    try {
      emit(LoadingState());
      var result = await repository.verifyPin({"email": email, "pin": pin});

      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future resendPin({required String email}) async {
    try {
      emit(LoadingState());
      var result = await repository.resendPin({"email": email});

      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future forgotPassword({required String email}) async {
    try {
      emit(LoadingState());
      var result = await repository.forgotPassword({"email": email});
      emit(LoadedState(result));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future doGoogleLogin() async {
    try {
      emit(LoadingState());

      // Kiểm tra Google Play Services trước
      final bool isGooglePlayServicesAvailable =
          await SocialLoginService.isGooglePlayServicesAvailable();

      if (!isGooglePlayServicesAvailable) {
        emit(
          ErrorState(AppLocalizations.current.google_play_services_not_available),
        );
        return;
      }

      final socialData = await SocialLoginService.signInWithGoogle();
      if (socialData == null) {
        emit(ErrorState(AppLocalizations.current.google_signin_failed));
        return;
      }

      AuthenModel authModel = await repository.mobileSocialLogin(socialData);

      // Lưu thông tin social login cho sinh trắc học
      await BiometricAuthService.storeSocialLoginInfo(socialData);
      // Gửi FCM token sau khi login thành công
      await _sendFCMTokenAfterLogin();
      emit(LoadedState(authModel));
    } catch (e) {
      String errorMessage = BlocUtils.getMessageError(e);
      emit(ErrorState(errorMessage));
    }
  }

  Future doFacebookLogin() async {
    try {
      emit(LoadingState());

      final socialData = await SocialLoginService.signInWithFacebook();
      if (socialData == null) {
        emit(InitState()); // User cancelled
        return;
      }

      AuthenModel authModel = await repository.mobileSocialLogin(socialData);

      // Lưu thông tin social login cho sinh trắc học
      await BiometricAuthService.storeSocialLoginInfo(socialData);

      // Gửi FCM token sau khi login thành công
      await _sendFCMTokenAfterLogin();

      emit(LoadedState(authModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  Future doMobileSocialLogin({
    required String platformId,
    required String email,
    required String fullName,
    required String platform,
    required String accessToken, // Bây giờ là required
    String? picture,
  }) async {
    try {
      emit(LoadingState());
      AuthenModel authModel = await repository.mobileSocialLogin({
        "platformId": platformId,
        "email": email,
        "fullName": fullName,
        "platform": platform,
        "picture": picture,
        "accessToken": accessToken, // Required cho token verification
      });

      // Gửi FCM token sau khi login thành công
      await _sendFCMTokenAfterLogin();

      emit(LoadedState(authModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Đăng nhập bằng sinh trắc học
  Future doBiometricLogin() async {
    try {
      emit(LoadingState());

      final result = await BiometricAuthService.loginWithBiometrics();
      if (result.isSuccess && result.data != null) {
        if (result.isSocialLogin) {
          // Đăng nhập lại bằng social
          final socialData = result.data!;
          AuthenModel authModel = await repository.mobileSocialLogin(socialData);

          // Gửi FCM token sau khi login thành công
          await _sendFCMTokenAfterLogin();

          emit(LoadedState(authModel));
        } else {
          // Đăng nhập bằng username/password
          // FCM token sẽ được gửi trong doLogin()
          final credentials = result.data!;
          await doLogin(
            username: credentials['username'],
            password: credentials['password'],
          );
        }
      } else {
        emit(ErrorState(result.message ?? 'Đăng nhập sinh trắc học thất bại'));
      }
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }

  /// Bật/tắt sinh trắc học và lưu thông tin đăng nhập
  Future toggleBiometric(
    bool enabled, {
    String? username,
    String? password,
  }) async {
    try {
      if (enabled) {
        // Kiểm tra khả năng sinh trắc học
        final capability =
            await BiometricAuthService.checkBiometricCapability();
        if (capability != BiometricCapability.available) {
          String message;
          switch (capability) {
            case BiometricCapability.notSupported:
              message = 'Thiết bị không hỗ trợ sinh trắc học';
              break;
            case BiometricCapability.notEnrolled:
              message =
                  'Chưa thiết lập sinh trắc học. Vui lòng thiết lập trong Cài đặt thiết bị';
              break;
            case BiometricCapability.notAvailable:
              message = 'Sinh trắc học không khả dụng';
              break;
            default:
              message = 'Lỗi không xác định';
          }
          throw Exception(message);
        }

        // Xác thực sinh trắc học trước khi bật
        final authResult =
            await BiometricAuthService.authenticateWithBiometrics(
              localizedReason: 'Xác thực để bật đăng nhập bằng sinh trắc học',
            );

        if (!authResult.isSuccess) {
          throw Exception(
            authResult.message ?? 'Xác thực sinh trắc học thất bại',
          );
        }

        // Lưu thông tin đăng nhập nếu có
        if (username != null && password != null) {
          await BiometricAuthService.storeCredentials(username, password);
        }

        // Bật sinh trắc học
        await BiometricAuthService.setBiometricEnabledInApp(true);
      } else {
        // Tắt sinh trắc học và xóa tất cả thông tin đăng nhập
        await BiometricAuthService.setBiometricEnabledInApp(false);
        await BiometricAuthService.clearAllStoredLoginInfo();
      }
    } catch (e) {
      throw Exception(BlocUtils.getMessageError(e));
    }
  }

  /// Kiểm tra trạng thái sinh trắc học
  Future<bool> isBiometricEnabled() async {
    return await BiometricAuthService.isBiometricEnabledInApp();
  }

  /// Kiểm tra khả năng sử dụng sinh trắc học
  Future<BiometricCapability> checkBiometricCapability() async {
    return await BiometricAuthService.checkBiometricCapability();
  }

  /// Cập nhật thông tin profile
  Future updateProfile({required UserModel userModel}) async {
    try {
      emit(LoadingState());
      // Repository sẽ tự động lưu vào secure storage
      UserModel updatedUserModel = await repository.updateProfile(userModel);
      emit(LoadedState(updatedUserModel));
    } catch (e) {
      emit(ErrorState(BlocUtils.getMessageError(e)));
    }
  }
}
