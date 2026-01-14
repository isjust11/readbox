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

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update profile'**
  String get update_profile;

  /// No description provided for @update_profile_success.
  ///
  /// In en, this message translates to:
  /// **'Update profile successfully'**
  String get update_profile_success;

  /// No description provided for @update_profile_failed.
  ///
  /// In en, this message translates to:
  /// **'Update profile failed'**
  String get update_profile_failed;

  /// No description provided for @update_profile_description.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get update_profile_description;

  /// No description provided for @update_profile_description_success.
  ///
  /// In en, this message translates to:
  /// **'Update your information successfully'**
  String get update_profile_description_success;

  /// No description provided for @update_profile_description_failed.
  ///
  /// In en, this message translates to:
  /// **'Update your information failed'**
  String get update_profile_description_failed;

  /// No description provided for @please_enter_instagram_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter Instagram link'**
  String get please_enter_instagram_link;

  /// No description provided for @please_enter_twitter_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter Twitter link'**
  String get please_enter_twitter_link;

  /// No description provided for @please_enter_linkedin_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter LinkedIn link'**
  String get please_enter_linkedin_link;

  /// No description provided for @please_enter_github_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter GitHub link'**
  String get please_enter_github_link;

  /// No description provided for @please_enter_gitlab_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter GitLab link'**
  String get please_enter_gitlab_link;

  /// No description provided for @please_enter_bitbucket_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter Bitbucket link'**
  String get please_enter_bitbucket_link;

  /// No description provided for @please_enter_facebook_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter Facebook link'**
  String get please_enter_facebook_link;

  /// No description provided for @please_enter_valid_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid birth date'**
  String get please_enter_valid_birth_date;

  /// No description provided for @please_enter_valid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid phone number'**
  String get please_enter_valid_phone_number;

  /// No description provided for @please_enter_valid_address.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid address'**
  String get please_enter_valid_address;

  /// No description provided for @please_enter_valid_facebook_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid Facebook link'**
  String get please_enter_valid_facebook_link;

  /// No description provided for @please_enter_valid_instagram_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid Instagram link'**
  String get please_enter_valid_instagram_link;

  /// No description provided for @please_enter_valid_twitter_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid Twitter link'**
  String get please_enter_valid_twitter_link;

  /// No description provided for @please_enter_valid_linkedin_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid LinkedIn link'**
  String get please_enter_valid_linkedin_link;

  /// No description provided for @please_enter_valid_github_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid GitHub link'**
  String get please_enter_valid_github_link;

  /// No description provided for @please_enter_valid_gitlab_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid GitLab link'**
  String get please_enter_valid_gitlab_link;

  /// No description provided for @please_enter_valid_bitbucket_link.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid Bitbucket link'**
  String get please_enter_valid_bitbucket_link;

  /// No description provided for @cannot_select_image_message.
  ///
  /// In en, this message translates to:
  /// **'Cannot select image'**
  String get cannot_select_image_message;

  /// No description provided for @cannot_access_camera.
  ///
  /// In en, this message translates to:
  /// **'Cannot access camera'**
  String get cannot_access_camera;

  /// No description provided for @please_grant_permission_to_access_camera_or_gallery_in_settings.
  ///
  /// In en, this message translates to:
  /// **'Please grant permission to access camera or gallery in settings'**
  String get please_grant_permission_to_access_camera_or_gallery_in_settings;

  /// No description provided for @no_available_camera.
  ///
  /// In en, this message translates to:
  /// **'No available camera'**
  String get no_available_camera;

  /// No description provided for @no_content_to_display.
  ///
  /// In en, this message translates to:
  /// **'No content to display'**
  String get no_content_to_display;

  /// No description provided for @privacy_and_security.
  ///
  /// In en, this message translates to:
  /// **'Privacy and security'**
  String get privacy_and_security;

  /// No description provided for @pdfEpubMobi.
  ///
  /// In en, this message translates to:
  /// **'PDF, EPUB, MOBI'**
  String get pdfEpubMobi;

  /// No description provided for @fileEbook.
  ///
  /// In en, this message translates to:
  /// **'File Ebook'**
  String get fileEbook;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_field;

  /// No description provided for @select_file.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get select_file;

  /// No description provided for @from_file_picker.
  ///
  /// In en, this message translates to:
  /// **'From file picker'**
  String get from_file_picker;

  /// No description provided for @in_memory.
  ///
  /// In en, this message translates to:
  /// **'In memory'**
  String get in_memory;

  /// No description provided for @ready_to_upload.
  ///
  /// In en, this message translates to:
  /// **'Ready to upload'**
  String get ready_to_upload;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @upload_file.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get upload_file;

  /// No description provided for @upload_success.
  ///
  /// In en, this message translates to:
  /// **'Upload success'**
  String get upload_success;

  /// No description provided for @cover_image.
  ///
  /// In en, this message translates to:
  /// **'Cover image'**
  String get cover_image;

  /// No description provided for @jpgPngWebp.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG, WEBP'**
  String get jpgPngWebp;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @select_cover_image.
  ///
  /// In en, this message translates to:
  /// **'Select cover image'**
  String get select_cover_image;

  /// No description provided for @recommended_size.
  ///
  /// In en, this message translates to:
  /// **'Recommended size'**
  String get recommended_size;

  /// No description provided for @upload_cover_image.
  ///
  /// In en, this message translates to:
  /// **'Upload cover image'**
  String get upload_cover_image;

  /// No description provided for @cover_image_uploaded_successfully.
  ///
  /// In en, this message translates to:
  /// **'Cover image uploaded successfully'**
  String get cover_image_uploaded_successfully;

  /// No description provided for @book_information.
  ///
  /// In en, this message translates to:
  /// **'Book information'**
  String get book_information;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @isbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbn;

  /// No description provided for @total_pages.
  ///
  /// In en, this message translates to:
  /// **'Total pages'**
  String get total_pages;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @book_will_be_displayed_for_everyone.
  ///
  /// In en, this message translates to:
  /// **'Book will be displayed for everyone'**
  String get book_will_be_displayed_for_everyone;

  /// No description provided for @book_will_be_displayed_for_admin.
  ///
  /// In en, this message translates to:
  /// **'Book will be displayed for admin'**
  String get book_will_be_displayed_for_admin;

  /// No description provided for @creating_book.
  ///
  /// In en, this message translates to:
  /// **'Creating book...'**
  String get creating_book;

  /// No description provided for @create_new_book.
  ///
  /// In en, this message translates to:
  /// **'Create new book'**
  String get create_new_book;

  /// No description provided for @please_enter_author.
  ///
  /// In en, this message translates to:
  /// **'Please enter author'**
  String get please_enter_author;

  /// No description provided for @please_enter_description.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get please_enter_description;

  /// No description provided for @please_enter_publisher.
  ///
  /// In en, this message translates to:
  /// **'Please enter publisher'**
  String get please_enter_publisher;

  /// No description provided for @please_enter_isbn.
  ///
  /// In en, this message translates to:
  /// **'Please enter ISBN'**
  String get please_enter_isbn;

  /// No description provided for @please_enter_total_pages.
  ///
  /// In en, this message translates to:
  /// **'Please enter total pages'**
  String get please_enter_total_pages;

  /// No description provided for @please_enter_category.
  ///
  /// In en, this message translates to:
  /// **'Please enter category'**
  String get please_enter_category;

  /// No description provided for @please_enter_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get please_enter_title;

  /// No description provided for @select_language.
  ///
  /// In en, this message translates to:
  /// **'Please enter language'**
  String get select_language;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Language translation'**
  String get translate;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text to speech'**
  String get textToSpeech;

  /// No description provided for @convertTextToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Convert text to speech'**
  String get convertTextToSpeech;

  /// No description provided for @library.
  ///
  /// In en, this message translates to:
  /// **'Ebook library'**
  String get library;

  /// No description provided for @ttsLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'TTS Language Settings'**
  String get ttsLanguageSettings;

  /// No description provided for @selectTTSLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select reading language'**
  String get selectTTSLanguage;

  /// No description provided for @ttsSettings.
  ///
  /// In en, this message translates to:
  /// **'TTS Settings'**
  String get ttsSettings;

  /// No description provided for @ttsSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reading speed'**
  String get ttsSpeed;

  /// No description provided for @ttsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get ttsVolume;

  /// No description provided for @ttsPitch.
  ///
  /// In en, this message translates to:
  /// **'Voice pitch'**
  String get ttsPitch;

  /// No description provided for @ttsVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoice;

  /// No description provided for @testTTS.
  ///
  /// In en, this message translates to:
  /// **'Test reading'**
  String get testTTS;

  /// No description provided for @ttsTestText.
  ///
  /// In en, this message translates to:
  /// **'Hello, this is a text-to-speech test.'**
  String get ttsTestText;

  /// No description provided for @noLanguagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No languages available'**
  String get noLanguagesAvailable;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current language'**
  String get currentLanguage;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available languages'**
  String get availableLanguages;

  /// No description provided for @selectVoice.
  ///
  /// In en, this message translates to:
  /// **'Select voice'**
  String get selectVoice;

  /// No description provided for @defaultVoice.
  ///
  /// In en, this message translates to:
  /// **'Default voice'**
  String get defaultVoice;

  /// No description provided for @readingSpeed.
  ///
  /// In en, this message translates to:
  /// **'Reading speed'**
  String get readingSpeed;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @veryFast.
  ///
  /// In en, this message translates to:
  /// **'Very fast'**
  String get veryFast;

  /// No description provided for @voicePitch.
  ///
  /// In en, this message translates to:
  /// **'Voice pitch'**
  String get voicePitch;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @playTest.
  ///
  /// In en, this message translates to:
  /// **'Play test'**
  String get playTest;

  /// No description provided for @stopTest.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopTest;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @errorChangingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Error changing language'**
  String get errorChangingLanguage;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get errorSavingSettings;

  /// No description provided for @ttsNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'TTS not initialized'**
  String get ttsNotInitialized;

  /// No description provided for @initializingTTS.
  ///
  /// In en, this message translates to:
  /// **'Initializing TTS...'**
  String get initializingTTS;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @disableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Disable notifications'**
  String get disableNotifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receivePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications from server'**
  String get receivePushNotifications;

  /// No description provided for @localNotifications.
  ///
  /// In en, this message translates to:
  /// **'Local Notifications'**
  String get localNotifications;

  /// No description provided for @receiveLocalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive reminders and local notifications'**
  String get receiveLocalNotifications;

  /// No description provided for @readingReminders.
  ///
  /// In en, this message translates to:
  /// **'Reading Reminders'**
  String get readingReminders;

  /// No description provided for @setReadingReminders.
  ///
  /// In en, this message translates to:
  /// **'Set daily reading reminders'**
  String get setReadingReminders;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @selectReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Select reminder time'**
  String get selectReminderTime;

  /// No description provided for @bookUpdates.
  ///
  /// In en, this message translates to:
  /// **'Book Updates'**
  String get bookUpdates;

  /// No description provided for @receiveBookUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for new books'**
  String get receiveBookUpdates;

  /// No description provided for @systemNotifications.
  ///
  /// In en, this message translates to:
  /// **'System Notifications'**
  String get systemNotifications;

  /// No description provided for @receiveSystemNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive app update notifications'**
  String get receiveSystemNotifications;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @enableSound.
  ///
  /// In en, this message translates to:
  /// **'Enable sound'**
  String get enableSound;

  /// No description provided for @notificationVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get notificationVibration;

  /// No description provided for @enableVibration.
  ///
  /// In en, this message translates to:
  /// **'Enable vibration'**
  String get enableVibration;

  /// No description provided for @notificationBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get notificationBadge;

  /// No description provided for @showBadge.
  ///
  /// In en, this message translates to:
  /// **'Show badge on app icon'**
  String get showBadge;

  /// No description provided for @notificationPreview.
  ///
  /// In en, this message translates to:
  /// **'Notification Preview'**
  String get notificationPreview;

  /// No description provided for @showPreview.
  ///
  /// In en, this message translates to:
  /// **'Show content on lock screen'**
  String get showPreview;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send test notification'**
  String get sendTestNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get testNotificationSent;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission required'**
  String get notificationPermissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'Permission granted'**
  String get permissionGranted;

  /// No description provided for @notificationCategories.
  ///
  /// In en, this message translates to:
  /// **'Notification Categories'**
  String get notificationCategories;

  /// No description provided for @manageNotificationCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage notification categories'**
  String get manageNotificationCategories;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications'**
  String get clearAllNotifications;

  /// No description provided for @notificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notificationsCleared;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get notificationHistory;

  /// No description provided for @viewNotificationHistory.
  ///
  /// In en, this message translates to:
  /// **'View notification history'**
  String get viewNotificationHistory;

  /// No description provided for @fcmToken.
  ///
  /// In en, this message translates to:
  /// **'FCM Token'**
  String get fcmToken;

  /// No description provided for @copyToken.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get copyToken;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied'**
  String get tokenCopied;

  /// No description provided for @refreshToken.
  ///
  /// In en, this message translates to:
  /// **'Refresh token'**
  String get refreshToken;

  /// No description provided for @tokenRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Token refreshed'**
  String get tokenRefreshed;

  /// No description provided for @notificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Notification Status'**
  String get notificationStatus;

  /// No description provided for @permissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Permission Status'**
  String get permissionStatus;

  /// No description provided for @new_book.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get new_book;

  /// No description provided for @read_book.
  ///
  /// In en, this message translates to:
  /// **'Read book'**
  String get read_book;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get view_details;

  /// No description provided for @add_favorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get add_favorite;

  /// No description provided for @remove_favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get remove_favorite;

  /// No description provided for @add_archive.
  ///
  /// In en, this message translates to:
  /// **'Add archive'**
  String get add_archive;

  /// No description provided for @remove_archive.
  ///
  /// In en, this message translates to:
  /// **'Remove archive'**
  String get remove_archive;

  /// No description provided for @file_ebook_not_found.
  ///
  /// In en, this message translates to:
  /// **'File ebook not found'**
  String get file_ebook_not_found;
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
