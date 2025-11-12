import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/locale_widget.dart';
import 'package:readbox/utils/navigator.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  MyApp();

  @override
  Widget build(BuildContext context) {
    return LocaleWidget(
      builder: (state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          navigatorKey: NavigationService.instance.navigatorKey,
          localizationsDelegates: [
            AppLocalizations.delegate, // Add this line
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: Locale(state),
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          localeResolutionCallback: (locale, supportedLocales) => _localeCallback(locale, supportedLocales),
          initialRoute: Routes.initScreen(),
          onGenerateRoute: Routes.generateRoute,
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
