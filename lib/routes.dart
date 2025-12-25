import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  Routes._();

  //screen name
  static const String splashScreen = "/splashScreen";
  static const String loginScreen = "/loginScreen";
  static const String registerScreen = "/registerScreen";
  static const String mainScreen = "/mainScreen";
  static const String libraryScreen = "/libraryScreen";
  static const String adminUploadScreen = "/adminUploadScreen";
  static const String bookDetailScreen = "/bookDetailScreen";
  static const String pdfViewerScreen = "/pdfViewerScreen";
  static const String newsListScreen = "/newsListScreen";
  static const String newsDetailScreen = "/newsDetailScreen";
  static const String newsCreateEditScreen = "/newsCreateEditScreen";

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
      case registerScreen:
        return PageTransition(child: RegisterScreen(), type: PageTransitionType.fade);
      case libraryScreen:
        return PageTransition(child: LibraryScreen(), type: PageTransitionType.fade);
      case adminUploadScreen:
        return PageTransition(child: AdminUploadScreen(), type: PageTransitionType.fade);
      case bookDetailScreen:
        final book = settings.arguments;
        return PageTransition(
          child: BookDetailScreen(book: book as BookModel),
          type: PageTransitionType.rightToLeft,
        );
      case pdfViewerScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: PdfViewerScreen(
            fileUrl: args['fileUrl'] as String,
            title: args['title'] as String,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case newsListScreen:
        return PageTransition(child: NewsListScreen(), type: PageTransitionType.fade);
      case newsDetailScreen:
        final news = settings.arguments;
        return PageTransition(
          child: NewsDetailScreen(news: news as NewsModel),
          type: PageTransitionType.rightToLeft,
        );
      case newsCreateEditScreen:
        final news = settings.arguments;
        return PageTransition(
          child: NewsCreateEditScreen(news: news as NewsModel?),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
