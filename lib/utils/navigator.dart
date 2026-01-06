import 'package:flutter/material.dart';
import 'package:readbox/gen/i18n/generated_locales/l10n.dart';
import 'package:readbox/routes.dart';
import 'package:readbox/ui/widget/custom_dialog.dart';

class NavigationService {
  NavigationService._internal();

  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  pushReplacement(String routeName) {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
    navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  popToRootView() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  pop() {
    navigatorKey.currentState?.pop();
  }

  popWithParam(param) {
    navigatorKey.currentState?.pop(param);
  }

}
