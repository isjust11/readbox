import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'locales/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('vi'),
    Locale('en'),
  ];

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @input_username.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get input_username;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @pls_input_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pls_input_username;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgot_password;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get reset_password;

  /// No description provided for @verify_email.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verify_email;

  /// No description provided for @verify_code.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verify_code;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get empty;

  /// No description provided for @pull_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pull_to_refresh;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @error_common.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please try again later'**
  String get error_common;

  /// No description provided for @agree.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get agree;

  /// No description provided for @disagree.
  ///
  /// In en, this message translates to:
  /// **'Disagree'**
  String get disagree;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @error_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_connection;

  /// No description provided for @my_library.
  ///
  /// In en, this message translates to:
  /// **'My library'**
  String get my_library;

  /// No description provided for @search_books.
  ///
  /// In en, this message translates to:
  /// **'Search books...'**
  String get search_books;

  /// No description provided for @favorite_books.
  ///
  /// In en, this message translates to:
  /// **'Favorite books'**
  String get favorite_books;

  /// No description provided for @archived_books.
  ///
  /// In en, this message translates to:
  /// **'Archived books'**
  String get archived_books;

  /// No description provided for @all_books.
  ///
  /// In en, this message translates to:
  /// **'All books'**
  String get all_books;

  /// No description provided for @public_books.
  ///
  /// In en, this message translates to:
  /// **'Public books'**
  String get public_books;

  /// No description provided for @private_books.
  ///
  /// In en, this message translates to:
  /// **'Private books'**
  String get private_books;

  /// No description provided for @my_books.
  ///
  /// In en, this message translates to:
  /// **'My books'**
  String get my_books;

  /// No description provided for @add_book.
  ///
  /// In en, this message translates to:
  /// **'Add book'**
  String get add_book;

  /// No description provided for @edit_book.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get edit_book;

  /// No description provided for @delete_book.
  ///
  /// In en, this message translates to:
  /// **'Delete book'**
  String get delete_book;

  /// No description provided for @all_data_loaded.
  ///
  /// In en, this message translates to:
  /// **'All data loaded'**
  String get all_data_loaded;

  /// No description provided for @add_book_to_start_reading.
  ///
  /// In en, this message translates to:
  /// **'Add book to start reading'**
  String get add_book_to_start_reading;

  /// No description provided for @no_books.
  ///
  /// In en, this message translates to:
  /// **'No books'**
  String get no_books;

  /// No description provided for @error_loading_books.
  ///
  /// In en, this message translates to:
  /// **'Error loading books'**
  String get error_loading_books;

  /// No description provided for @retry_loading_books.
  ///
  /// In en, this message translates to:
  /// **'Retry loading books'**
  String get retry_loading_books;

  /// No description provided for @loading_books.
  ///
  /// In en, this message translates to:
  /// **'Loading books'**
  String get loading_books;

  /// No description provided for @loading_more_books.
  ///
  /// In en, this message translates to:
  /// **'Loading more books'**
  String get loading_more_books;

  /// No description provided for @loading_more_books_failed.
  ///
  /// In en, this message translates to:
  /// **'Loading more books failed'**
  String get loading_more_books_failed;

  /// No description provided for @loading_more_books_completed.
  ///
  /// In en, this message translates to:
  /// **'Loading more books completed'**
  String get loading_more_books_completed;

  /// No description provided for @loading_more_books_no_data.
  ///
  /// In en, this message translates to:
  /// **'Loading more books no data'**
  String get loading_more_books_no_data;

  /// No description provided for @local_library.
  ///
  /// In en, this message translates to:
  /// **'Local library'**
  String get local_library;

  /// No description provided for @upload_book.
  ///
  /// In en, this message translates to:
  /// **'Upload book'**
  String get upload_book;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @google_play_services_not_available.
  ///
  /// In en, this message translates to:
  /// **'Google Play Services not available'**
  String get google_play_services_not_available;

  /// No description provided for @user_cancelled_google_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled Google sign in'**
  String get user_cancelled_google_sign_in;

  /// No description provided for @user_cancelled_facebook_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled Facebook sign in'**
  String get user_cancelled_facebook_sign_in;

  /// No description provided for @user_cancelled_apple_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled Apple sign in'**
  String get user_cancelled_apple_sign_in;

  /// No description provided for @user_cancelled_twitter_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled Twitter sign in'**
  String get user_cancelled_twitter_sign_in;

  /// No description provided for @user_cancelled_linkedin_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled LinkedIn sign in'**
  String get user_cancelled_linkedin_sign_in;

  /// No description provided for @user_cancelled_github_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled GitHub sign in'**
  String get user_cancelled_github_sign_in;

  /// No description provided for @user_cancelled_gitlab_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled GitLab sign in'**
  String get user_cancelled_gitlab_sign_in;

  /// No description provided for @user_cancelled_bitbucket_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled Bitbucket sign in'**
  String get user_cancelled_bitbucket_sign_in;

  /// No description provided for @user_cancelled_sign_in.
  ///
  /// In en, this message translates to:
  /// **'User cancelled sign in'**
  String get user_cancelled_sign_in;

  /// No description provided for @google_signin_failed.
  ///
  /// In en, this message translates to:
  /// **'Google signin failed'**
  String get google_signin_failed;

  /// No description provided for @google_network_error.
  ///
  /// In en, this message translates to:
  /// **'Google network error'**
  String get google_network_error;

  /// No description provided for @google_invalid_client.
  ///
  /// In en, this message translates to:
  /// **'Google invalid client'**
  String get google_invalid_client;

  /// No description provided for @google_developer_error.
  ///
  /// In en, this message translates to:
  /// **'Google developer error'**
  String get google_developer_error;

  /// No description provided for @google_timeout.
  ///
  /// In en, this message translates to:
  /// **'Google timeout'**
  String get google_timeout;

  /// No description provided for @facebook_access_token_is_null.
  ///
  /// In en, this message translates to:
  /// **'Facebook access token is null'**
  String get facebook_access_token_is_null;

  /// No description provided for @facebook_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Facebook login failed'**
  String get facebook_login_failed;

  /// No description provided for @facebook_network_error.
  ///
  /// In en, this message translates to:
  /// **'Facebook network error'**
  String get facebook_network_error;

  /// No description provided for @facebook_invalid_client.
  ///
  /// In en, this message translates to:
  /// **'Facebook invalid client'**
  String get facebook_invalid_client;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @updateYourInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInfo;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get privacySettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @chooseAppAppearance.
  ///
  /// In en, this message translates to:
  /// **'Choose app appearance'**
  String get chooseAppAppearance;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get biometricLogin;

  /// No description provided for @biometricNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available'**
  String get biometricNotAvailable;

  /// No description provided for @useFingerprintOrFaceID.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or Face ID'**
  String get useFingerprintOrFaceID;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @getHelpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @shareYourThoughts.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts'**
  String get shareYourThoughts;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @noLoginInfo.
  ///
  /// In en, this message translates to:
  /// **'No login information'**
  String get noLoginInfo;

  /// No description provided for @biometricSetupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric setup successful'**
  String get biometricSetupSuccess;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric disabled'**
  String get biometricDisabled;

  /// No description provided for @feedbackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent successfully'**
  String get feedbackSuccess;

  /// No description provided for @feedbackContact.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get feedbackContact;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'We would love to hear your feedback to improve the app'**
  String get feedbackDescription;

  /// No description provided for @feedbackType.
  ///
  /// In en, this message translates to:
  /// **'Feedback type'**
  String get feedbackType;

  /// No description provided for @feedbackPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get feedbackPriority;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get feedbackTitle;

  /// No description provided for @feedbackTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get feedbackTitleRequired;

  /// No description provided for @feedbackTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters'**
  String get feedbackTitleMinLength;

  /// No description provided for @feedbackContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get feedbackContent;

  /// No description provided for @feedbackContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter content'**
  String get feedbackContentRequired;

  /// No description provided for @feedbackContentMinLength.
  ///
  /// In en, this message translates to:
  /// **'Content must be at least 10 characters'**
  String get feedbackContentMinLength;

  /// No description provided for @feedbackName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get feedbackName;

  /// No description provided for @feedbackEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get feedbackEmailInvalid;

  /// No description provided for @feedbackPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get feedbackPhone;

  /// No description provided for @feedbackPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get feedbackPhoneInvalid;

  /// No description provided for @feedbackOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get feedbackOptions;

  /// No description provided for @feedbackAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Send anonymously'**
  String get feedbackAnonymous;

  /// No description provided for @feedbackAnonymousDescription.
  ///
  /// In en, this message translates to:
  /// **'Send feedback without displaying personal information'**
  String get feedbackAnonymousDescription;

  /// No description provided for @feedbackSend.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get feedbackSend;

  /// No description provided for @login_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue'**
  String get login_to_continue;

  /// No description provided for @register_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Register to continue'**
  String get register_to_continue;

  /// No description provided for @register_now.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get register_now;

  /// No description provided for @login_now.
  ///
  /// In en, this message translates to:
  /// **'Login now'**
  String get login_now;

  /// No description provided for @login_with_google.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get login_with_google;

  /// No description provided for @login_with_facebook.
  ///
  /// In en, this message translates to:
  /// **'Login with Facebook'**
  String get login_with_facebook;

  /// No description provided for @login_with_apple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get login_with_apple;

  /// No description provided for @login_with_twitter.
  ///
  /// In en, this message translates to:
  /// **'Login with Twitter'**
  String get login_with_twitter;

  /// No description provided for @login_with_linkedin.
  ///
  /// In en, this message translates to:
  /// **'Login with LinkedIn'**
  String get login_with_linkedin;

  /// No description provided for @login_with_github.
  ///
  /// In en, this message translates to:
  /// **'Login with GitHub'**
  String get login_with_github;

  /// No description provided for @login_with_gitlab.
  ///
  /// In en, this message translates to:
  /// **'Login with GitLab'**
  String get login_with_gitlab;

  /// No description provided for @login_with_bitbucket.
  ///
  /// In en, this message translates to:
  /// **'Login with Bitbucket'**
  String get login_with_bitbucket;

  /// No description provided for @login_with_email.
  ///
  /// In en, this message translates to:
  /// **'Login with email'**
  String get login_with_email;

  /// No description provided for @login_with_phone.
  ///
  /// In en, this message translates to:
  /// **'Login with phone'**
  String get login_with_phone;

  /// No description provided for @login_with_username.
  ///
  /// In en, this message translates to:
  /// **'Login with username'**
  String get login_with_username;

  /// No description provided for @login_with_password.
  ///
  /// In en, this message translates to:
  /// **'Login with password'**
  String get login_with_password;

  /// No description provided for @login_with_otp.
  ///
  /// In en, this message translates to:
  /// **'Login with OTP'**
  String get login_with_otp;

  /// No description provided for @login_with_pin.
  ///
  /// In en, this message translates to:
  /// **'Login with PIN'**
  String get login_with_pin;

  /// No description provided for @login_with_face_id.
  ///
  /// In en, this message translates to:
  /// **'Login with Face ID'**
  String get login_with_face_id;

  /// No description provided for @login_with_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Login with fingerprint'**
  String get login_with_fingerprint;

  /// No description provided for @login_with_biometric.
  ///
  /// In en, this message translates to:
  /// **'Login with biometric'**
  String get login_with_biometric;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcome_back;

  /// No description provided for @enter_username.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enter_username;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enter_password;

  /// No description provided for @please_enter_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get please_enter_username;

  /// No description provided for @please_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get please_enter_password;

  /// No description provided for @password_must_be_at_least_6_characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_must_be_at_least_6_characters;

  /// No description provided for @no_account.
  ///
  /// In en, this message translates to:
  /// **'No account? '**
  String get no_account;

  /// No description provided for @have_account.
  ///
  /// In en, this message translates to:
  /// **'Have account? '**
  String get have_account;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get full_name;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirm_password;

  /// No description provided for @enter_email.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enter_email;

  /// No description provided for @enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone;

  /// No description provided for @enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enter_full_name;

  /// No description provided for @enter_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Enter confirm password'**
  String get enter_confirm_password;

  /// No description provided for @please_enter_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm password'**
  String get please_enter_confirm_password;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @creating_account.
  ///
  /// In en, this message translates to:
  /// **'Creating account...'**
  String get creating_account;

  /// No description provided for @create_new_account.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get create_new_account;

  /// No description provided for @enter_information_to_start.
  ///
  /// In en, this message translates to:
  /// **'Enter information to start'**
  String get enter_information_to_start;

  /// No description provided for @please_enter_full_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get please_enter_full_name;

  /// No description provided for @please_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get please_enter_email;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalid_email;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @logging_in.
  ///
  /// In en, this message translates to:
  /// **'Logging in...'**
  String get logging_in;

  /// No description provided for @resend_code.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resend_code;

  /// No description provided for @back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get back_to_login;

  /// No description provided for @email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Email invalid'**
  String get email_invalid;

  /// No description provided for @please_enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get please_enter_phone;

  /// No description provided for @please_enter_code.
  ///
  /// In en, this message translates to:
  /// **'Please enter code'**
  String get please_enter_code;

  /// No description provided for @please_enter_confirm_code.
  ///
  /// In en, this message translates to:
  /// **'Please enter confirm code'**
  String get please_enter_confirm_code;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
