import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:readbox/config/theme_data.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/blocs/theme_cubit.dart';
import 'package:readbox/ui/widget/locale_widget.dart';
import 'package:readbox/utils/navigator.dart';
import 'package:readbox/services/services.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FCMService _fcmService = FCMService();
  final LocalNotificationService _localNotificationService = LocalNotificationService();
  final NotificationHandler _notificationHandler = NotificationHandler();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 Initializing notification services...');
      
      // Initialize FCM Service
      await _fcmService.initialize();
      debugPrint('✅ FCM Service initialized');
      debugPrint('   FCM Token: ${_fcmService.fcmToken}');
      
      // Initialize Local Notification Service
      await _localNotificationService.initialize();
      debugPrint('✅ Local Notification Service initialized');
      
      setState(() {
        _isInitialized = true;
      });
      
      debugPrint('✅ All notification services initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notification services: $e');
      setState(() {
        _isInitialized = true; // Set to true anyway to allow app to continue
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocaleWidget(
      builder: (languageState) {
        return BlocBuilder<ThemeCubit, String>(
          builder: (context, themeState) {
            return MaterialApp(
              key: ValueKey('${languageState}_$themeState'),
              debugShowCheckedModeBanner: false,
              navigatorObservers: [routeObserver],
              navigatorKey: NavigationService.instance.navigatorKey,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: Locale(languageState),
              supportedLocales: AppLocalizations.delegate.supportedLocales,
              localeResolutionCallback: (locale, supportedLocales) => _localeCallback(locale, supportedLocales),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState == 'dark' ? ThemeMode.dark : ThemeMode.light,
              initialRoute: Routes.initScreen(),
              onGenerateRoute: Routes.generateRoute,
              builder: (context, child) {
                // Set notification handler context when navigator is ready
                if (_isInitialized) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final navigatorContext = NavigationService.instance.navigatorKey.currentContext;
                    if (navigatorContext != null) {
                      _notificationHandler.setContext(navigatorContext);
                    }
                  });
                }
                return child ?? const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }

  Locale _localeCallback(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) {
      return supportedLocales.first;
    }
    // Check if the current device locale is supported
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }
    // If the locale of the device is not supported, use the first one
    // from the list (japanese, in this case).
    return supportedLocales.first;
  }
}
