import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  Routes._();

  //screen name
  static const String splashScreen = "/splashScreen";
  static const String loginScreen = "/loginScreen";
  static const String mainScreen = "/mainScreen";
  static const String libraryScreen = "/libraryScreen";

  //init screen name
  static String initScreen() => splashScreen;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainScreen:
        return PageTransition(child: MainScreen(), type: PageTransitionType.fade);
      case splashScreen:
        return PageTransition(child: SplashScreen(), type: PageTransitionType.fade);
      case loginScreen:
        return PageTransition(child: LoginScreen(), type: PageTransitionType.fade);
      case libraryScreen:
        return PageTransition(child: LibraryScreen(), type: PageTransitionType.fade);
      default:
        return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
