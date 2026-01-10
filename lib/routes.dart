import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/auth/forgot_password_screen.dart';
import 'package:readbox/ui/screen/book/pdf_viewer_demo_screen.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:page_transition/page_transition.dart';

class Routes {
  Routes._();

  //screen name
  static const String splashScreen = "/splashScreen";
  static const String loginScreen = "/loginScreen";
  static const String registerScreen = "/registerScreen";
  static const String confirmPinScreen = "/confirmPinScreen";
  static const String mainScreen = "/mainScreen";
  static const String libraryScreen = "/libraryScreen";
  static const String localLibraryScreen = "/localLibraryScreen";
  static const String adminUploadScreen = "/adminUploadScreen";
  static const String bookDetailScreen = "/bookDetailScreen";
  static const String pdfViewerScreen = "/pdfViewerScreen";
  static const String pdfViewerWithSelectionScreen =
      "/pdfViewerWithSelectionScreen";
  static const String pdfViewerAdvancedScreen = "/pdfViewerAdvancedScreen";
  static const String adminPdfScannerScreen = "/adminPdfScannerScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String feedbackScreen = "/feedbackScreen";
  static const String forgotPassword = "/forgotPassword";
  static const String editProfile = "/editProfile";
  static const String privacySecurityScreen = "/privacySecurityScreen";
  static const String supportCenterScreen = "/supportCenterScreen";
  static const String profileScreen = "/profileScreen";
  static const String translateScreen = "/translateScreen";
  static const String textToSpeechSettingScreen = "/textToSpeechSettingScreen";
  // PDF text to speech screen
  static const String pdfTextToSpeechScreen = "/pdfTextToSpeechScreen";
  static const String ttsDemoScreen = "/ttsDemoScreen";

  static const String search = "/search";
  //init screen name
  static String initScreen() => splashScreen;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainScreen:
        return PageTransition(
          child: MainScreen(),
          type: PageTransitionType.fade,
        );
      case splashScreen:
        return PageTransition(
          child: SplashScreen(),
          type: PageTransitionType.fade,
        );
      case loginScreen:
        return PageTransition(
          child: LoginScreen(),
          type: PageTransitionType.fade,
        );
      case registerScreen:
        return PageTransition(
          child: RegisterScreen(),
          type: PageTransitionType.fade,
        );
      case forgotPassword:
        return PageTransition(
          child: ForgotPasswordScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case confirmPinScreen:
        final email = settings.arguments as String?;
        return PageTransition(
          child: ConfirmPinScreen(email: email ?? ''),
          type: PageTransitionType.rightToLeft,
        );
      case libraryScreen:
        return PageTransition(
          child: LibraryScreen(),
          type: PageTransitionType.fade,
        );
      case localLibraryScreen:
        return PageTransition(
          child: LocalLibraryScreen(),
          type: PageTransitionType.fade,
        );
      case adminUploadScreen:
        return PageTransition(
          child: AdminUploadScreen(),
          type: PageTransitionType.fade,
        );
      case pdfTextToSpeechScreen:
        return PageTransition(
          child: PdfViewerDemoScreen(),
          type: PageTransitionType.fade,
        );
      case bookDetailScreen:
        final book = settings.arguments;
        return PageTransition(
          child: BookDetailScreen(book: book as BookModel),
          type: PageTransitionType.rightToLeft,
        );
      case settingsScreen:
        return PageTransition(
          child: SettingScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case feedbackScreen:
        return PageTransition(
          child: FeedbackScreen(),
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
      case pdfViewerWithSelectionScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: PdfViewerWithSelectionScreen(
            fileUrl: args['fileUrl'] as String,
            title: args['title'] as String,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case pdfViewerAdvancedScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return PageTransition(
          child: PdfViewerAdvancedScreen(
            fileUrl: args['fileUrl'] as String,
            title: args['title'] as String,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case editProfile:
        return PageTransition(
          child: UpdateProfileScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case privacySecurityScreen:
        return PageTransition(
          child: PrivacySecurityScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case supportCenterScreen:
        return PageTransition(
          child: SupportCenterScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case profileScreen:
        return PageTransition(
          child: ProfileScreen(user: settings.arguments as UserModel?),
          type: PageTransitionType.rightToLeft,
        );
      case translateScreen:
        return PageTransition(
          child: TranslateScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case textToSpeechSettingScreen:
        return PageTransition(
          child: TextToSpeechSettingScreen(),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
