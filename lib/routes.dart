import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/auth/forgot_password_screen.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:page_transition/page_transition.dart';
import 'package:readbox/ui/screen/tools/tools_screen.dart';


class Routes {
  Routes._();

  //screen name
  static const String splashScreen = "/splashScreen";
  static const String loginScreen = "/loginScreen";
  static const String registerScreen = "/registerScreen";
  static const String confirmPinScreen = "/confirmPinScreen";
  static const String mainScreen = "/mainScreen";
  static const String localLibraryScreen = "/localLibraryScreen";
  static const String adminUploadScreen = "/adminUploadScreen";
  static const String bookDetailScreen = "/bookDetailScreen";
  static const String pdfViewerScreen = "/pdfViewerScreen";
  static const String settingsScreen = "/settingsScreen";
  static const String feedbackScreen = "/feedbackScreen";
  static const String forgotPassword = "/forgotPassword";
  static const String editProfile = "/editProfile";
  static const String privacySecurityScreen = "/privacySecurityScreen";
  static const String supportCenterScreen = "/supportCenterScreen";
  static const String profileScreen = "/profileScreen";
  static const String translateScreen = "/translateScreen";
  static const String textToSpeechSettingScreen = "/textToSpeechSettingScreen";
  static const String notificationSettingsScreen =
      "/notificationSettingsScreen";
  static const String notificationScreen = "/notificationScreen";
  static const String notificationDetailScreen = "/notificationDetailScreen";
  static const String toolsScreen = "/toolsScreen";
  static const String reviewsScreen = "/reviewsScreen";

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
      case localLibraryScreen:
        return PageTransition(
          child: LocalLibraryScreen(),
          type: PageTransitionType.fade,
        );
      case adminUploadScreen:
        if (settings.arguments == null) {
          return PageTransition(
            child: AdminUploadScreen(),
            type: PageTransitionType.fade,
          );
        }
        final book = settings.arguments as BookModel;
        return PageTransition(
          child: AdminUploadScreen(
            book: book,
          ),
          type: PageTransitionType.fade,
        );
      case bookDetailScreen:
        final bookId = settings.arguments as String;
        return PageTransition(
          child: BookDetailScreen(bookId: bookId),
          type: PageTransitionType.rightToLeft,
        );
      case settingsScreen:
      final user = settings.arguments as UserModel;
        return PageTransition(
          child: SettingScreen(user: user),
          type: PageTransitionType.rightToLeft,
        );
      case feedbackScreen:
        return PageTransition(
          child: FeedbackScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case pdfViewerScreen:
        final args = settings.arguments as BookModel;
        return PageTransition(
          child: PdfViewerScreen(
            fileUrl: args.fileUrl!,
            title: args.displayTitle,
            userIdCreate: args.createById,
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
      // case notificationSettingsScreen:
      //   return PageTransition(
      //     child: NotificationSettingsScreen(),
      //     type: PageTransitionType.rightToLeft,
      //   );
      case notificationDetailScreen:
        final notification = settings.arguments as NotificationModel;
        return PageTransition(
          child: NotificationDetailScreen(notification: notification),
          type: PageTransitionType.rightToLeft,
        );
      case notificationScreen:
        return PageTransition(
          child: NotificationScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case toolsScreen:
        return PageTransition(
          child: ToolsScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case reviewsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          child: ReviewsScreen(
            bookId: args?['bookId'] as String? ?? '',
            bookTitle: args?['bookTitle'] as String?,
            averageRating: (args?['averageRating'] as num?)?.toDouble(),
            totalRatings: args?['totalRatings'] as int?,
          ),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
