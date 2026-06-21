import 'package:flutter/material.dart';
import 'package:readbox/ui/screen/auth/forgot_password_screen.dart';
import 'package:readbox/ui/screen/screen.dart';
import 'package:readbox/domain/data/models/models.dart';
import 'package:readbox/res/res.dart';
import 'package:page_transition/page_transition.dart';
import 'package:readbox/ui/screen/tools/tools_screen.dart';
import 'package:readbox/ui/screen/settings/page/theme_customization_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readbox/blocs/library/library_cubit.dart';
import 'package:readbox/domain/repositories/repositories.dart';
import 'package:readbox/domain/data/datasources/remote/admin_remote_data_source.dart';
import 'package:readbox/injection_container.dart' as di;

class Routes {
  Routes._();

  //screen name
  static const String splashScreen = "/splashScreen";
  static const String loginScreen = "/loginScreen";
  static const String registerScreen = "/registerScreen";
  static const String confirmPinScreen = "/confirmPinScreen";
  static const String mainScreen = "/mainScreen";
  static const String allEbooksScreen = "/allEbooksScreen";
  static const String localLibraryScreen = "/localLibraryScreen";
  static const String adminUploadScreen = "/adminUploadScreen";
  static const String bookDetailScreen = "/bookDetailScreen";
  static const String pdfViewerScreen = "/pdfViewerScreen";
  static const String epubViewerScreen = "/epubViewerScreen";
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
  static const String dataStorageScreen = "/dataStorageScreen";
  static const String subscriptionPlanScreen = "/subscriptionPlanScreen";
  static const String paymentHistoryScreen = "/paymentHistoryScreen";
  static const String themeCustomizationScreen = "/themeCustomizationScreen";

  static const String search = "/search";
  //init screen name
  static String initScreen() => splashScreen;

  /// Truyền [settings] vào PageTransition để route.settings.name
  /// không bị null — cần thiết cho _DeepLinkRouteObserver trong app.dart
  /// để biết màn hình đang hiển thị là gì.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainScreen:
        return PageTransition(
          settings: settings,
          child: const DiscoverScreen(),
          type: PageTransitionType.fade,
        );
      case allEbooksScreen:
        // Cho phép truyền FilterType qua arguments để Discover điều hướng tới
        // với filter tương ứng (vd: từ section "Yêu thích" → mở thẳng favorites).
        final filter = settings.arguments is FilterType
            ? settings.arguments as FilterType
            : null;
        return PageTransition(
          settings: settings,
          child: AllEbooksScreen(initialFilter: filter),
          type: PageTransitionType.fade,
        );
      case splashScreen:
        return PageTransition(
          settings: settings,
          child: SplashScreen(),
          type: PageTransitionType.fade,
        );
      case loginScreen:
        return PageTransition(
          settings: settings,
          child: LoginScreen(),
          type: PageTransitionType.fade,
        );
      case registerScreen:
        return PageTransition(
          settings: settings,
          child: RegisterScreen(),
          type: PageTransitionType.fade,
        );
      case forgotPassword:
        final username = settings.arguments as String?;
        return PageTransition(
          settings: settings,
          child: ForgotPasswordScreen(username: username),
          type: PageTransitionType.rightToLeft,
        );
      case confirmPinScreen:
        final email = settings.arguments as String?;
        return PageTransition(
          settings: settings,
          child: ConfirmPinScreen(email: email ?? ''),
          type: PageTransitionType.rightToLeft,
        );
      case localLibraryScreen:
        return PageTransition(
          settings: settings,
          child: LocalLibraryScreen(),
          type: PageTransitionType.fade,
        );
      case adminUploadScreen:
        if (settings.arguments == null) {
          return PageTransition(
            settings: settings,
            child: BlocProvider(
              create:
                  (context) => LibraryCubit(
                    repository: di.getIt<BookRepository>(),
                    adminRemoteDataSource: di.getIt<AdminRemoteDataSource>(),
                  ),
              child: AdminUploadScreen(),
            ),
            type: PageTransitionType.fade,
          );
        }
        final book = settings.arguments as BookModel;
        return PageTransition(
          settings: settings,
          child: BlocProvider(
            create:
                (context) => LibraryCubit(
                  repository: di.getIt<BookRepository>(),
                  adminRemoteDataSource: di.getIt<AdminRemoteDataSource>(),
                ),
            child: AdminUploadScreen(book: book),
          ),
          type: PageTransitionType.fade,
        );
      case bookDetailScreen:
        final bookId = settings.arguments as String;
        return PageTransition(
          settings: settings,
          child: BookDetailScreen(bookId: bookId),
          type: PageTransitionType.rightToLeft,
        );
      case settingsScreen:
        final user = settings.arguments as UserModel;
        return PageTransition(
          settings: settings,
          child: SettingScreen(user: user),
          type: PageTransitionType.rightToLeft,
        );
      case feedbackScreen:
        return PageTransition(
          settings: settings,
          child: FeedbackScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case pdfViewerScreen:
        final args = settings.arguments as BookModel;
        return PageTransition(
          settings: settings,
          child: PdfViewerScreen(
            fileUrl: args.fileUrl!,
            bookId: args.id,
            title: args.displayTitle,
            userIdCreate: args.createById,
            thumbnailUrl: args.coverImageUrl,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case epubViewerScreen:
        final args = settings.arguments as BookModel;
        return PageTransition(
          settings: settings,
          child: EpubViewerScreen(
            fileUrl: args.fileUrl!,
            bookId: args.id,
            title: args.displayTitle,
            userIdCreate: args.createById,
            thumbnailUrl: args.coverImageUrl,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case editProfile:
        return PageTransition(
          settings: settings,
          child: UpdateProfileScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case privacySecurityScreen:
        return PageTransition(
          settings: settings,
          child: PrivacySecurityScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case supportCenterScreen:
        return PageTransition(
          settings: settings,
          child: SupportCenterScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case profileScreen:
        return PageTransition(
          settings: settings,
          child: ProfileScreen(user: settings.arguments as UserModel?),
          type: PageTransitionType.rightToLeft,
        );
      case translateScreen:
        return PageTransition(
          settings: settings,
          child: TranslateScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case textToSpeechSettingScreen:
        return PageTransition(
          settings: settings,
          child: TextToSpeechSettingScreen(),
          type: PageTransitionType.rightToLeft,
        );
      // case notificationSettingsScreen:
      //   return PageTransition(
      //     settings: settings,
      //     child: NotificationSettingsScreen(),
      //     type: PageTransitionType.rightToLeft,
      //   );
      case notificationDetailScreen:
        final notification = settings.arguments as NotificationModel;
        return PageTransition(
          settings: settings,
          child: NotificationDetailScreen(notification: notification),
          type: PageTransitionType.rightToLeft,
        );
      case notificationScreen:
        return PageTransition(
          settings: settings,
          child: NotificationScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case toolsScreen:
        return PageTransition(
          settings: settings,
          child: ToolsScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case reviewsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return PageTransition(
          settings: settings,
          child: ReviewsScreen(
            bookId: args?['bookId'] as String? ?? '',
            bookTitle: args?['bookTitle'] as String?,
            averageRating: (args?['averageRating'] as num?)?.toDouble(),
            totalRatings: args?['totalRatings'] as int?,
          ),
          type: PageTransitionType.rightToLeft,
        );
      case dataStorageScreen:
        return PageTransition(
          settings: settings,
          child: DataStorageScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case subscriptionPlanScreen:
        return PageTransition(
          settings: settings,
          child: SubscriptionPlanScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case paymentHistoryScreen:
        return PageTransition(
          settings: settings,
          child: PaymentHistoryScreen(),
          type: PageTransitionType.rightToLeft,
        );
      case themeCustomizationScreen:
        return PageTransition(
          settings: settings,
          child: const ThemeCustomizationScreen(),
          type: PageTransitionType.rightToLeft,
        );
      default:
        return MaterialPageRoute(builder: (context) => Container());
    }
  }
}
