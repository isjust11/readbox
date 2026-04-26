import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:readbox/blocs/cubit.dart';
import 'package:readbox/domain/data/datasources/remote/admin_remote_data_source.dart';
import 'package:readbox/domain/network/api_constant.dart';
import 'package:readbox/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/services/fcm_service.dart';
import 'injection_container.dart' as di;
import 'ui/app.dart';
import 'services/revenuecat_service.dart';
import 'utils/language_detector.dart';
import 'utils/shared_preference.dart';
import 'utils/tts_lock_screen_controller.dart';
import 'blocs/theme_state.dart';

/// Map locale hệ thống sang mã ngôn ngữ app hỗ trợ (vi, en).
String _languageFromSystemLocale() {
  final locale = PlatformDispatcher.instance.locale;
  final supported = AppLocalizationDelegate().supportedLocales;
  for (final supportedLocale in supported) {
    if (supportedLocale.languageCode == locale.languageCode) {
      return supportedLocale.languageCode;
    }
  }
  return supported.first.languageCode;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  RevenueCatService.instance.init();
  ApiConstant().init();
  // init theme data
  await ThemeCubit.init();
  await initLanguageDetector();
  await di.init();
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Lần đầu mở app (chưa có ngôn ngữ lưu): dùng ngôn ngữ hệ thống và lưu lại
  String language;
  final savedLanguage = await SharedPreferenceUtil.getSavedLanguage();
  if (savedLanguage == null || savedLanguage.isEmpty) {
    language = _languageFromSystemLocale();
    await SharedPreferenceUtil.setCurrentLanguage(language);
  } else {
    language = savedLanguage;
  }
  final themeStateJson = await SharedPreferenceUtil.getAppThemeStateJson();
  AppThemeState themeState;
  if (themeStateJson != null) {
    themeState = AppThemeState.fromJson(themeStateJson);
  } else {
    String themeStr = await SharedPreferenceUtil.getTheme();
    themeState = AppThemeState(themeMode: themeStr);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit(language)),
        BlocProvider(
          create: (_) => AuthCubit(repository: di.getIt<AuthRepository>()),
        ),
        BlocProvider(create: (_) => BookRefreshCubit()),
        BlocProvider(create: (_) => ThemeCubit(themeState)),
        BlocProvider(
          create:
              (_) => UserInteractionCubit(
                repository: di.getIt<UserInteractionRepository>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => NotificationCubit(
                notificationRepository: di.getIt<NotificationRepository>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => CategoryCubit(repository: di.getIt<CategoryRepository>()),
        ),
        BlocProvider(
          create:
              (_) => UserSubscriptionCubit(
                repository: di.getIt<UserSubscriptionRepository>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => LibraryCubit(
                repository: di.getIt<BookRepository>(),
                adminRemoteDataSource: di.getIt<AdminRemoteDataSource>(),
              ),
        ),
        BlocProvider(
          create:
              (_) => SubscriptionPlanCubit(
                repository: di.getIt<SubscriptionRepository>(),
              ),
        ),
      ],
      child: MyApp(),
    ),
  );

  // Init lock-screen TTS asynchronously to avoid blocking app startup.
  Future<void>(() async {
    try {
      await TtsLockScreenController.instance.initialize();
    } catch (_) {}
  });
}
