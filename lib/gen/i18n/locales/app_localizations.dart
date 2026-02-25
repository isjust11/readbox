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

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'ReadBox'**
  String get app_name;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

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

  /// No description provided for @years_ago.
  ///
  /// In en, this message translates to:
  /// **'years ago'**
  String get years_ago;

  /// No description provided for @months_ago.
  ///
  /// In en, this message translates to:
  /// **'months ago'**
  String get months_ago;

  /// No description provided for @days_ago.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get days_ago;

  /// No description provided for @hours_ago.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hours_ago;

  /// No description provided for @minutes_ago.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutes_ago;

  /// No description provided for @just_now.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get just_now;

  /// No description provided for @error_connection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_connection;

  /// No description provided for @error_cancel.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get error_cancel;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout, please try again later!'**
  String get error_timeout;

  /// No description provided for @error_request_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout, please try again later!'**
  String get error_request_timeout;

  /// No description provided for @error_internal_server_error.
  ///
  /// In en, this message translates to:
  /// **'Internal server error, please try again later!'**
  String get error_internal_server_error;

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

  /// No description provided for @book_discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get book_discover;

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
  /// **'On device'**
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

  /// No description provided for @username_must_be_at_least_3_characters.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get username_must_be_at_least_3_characters;

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

  /// No description provided for @please_enter_review.
  ///
  /// In en, this message translates to:
  /// **'Please enter review, at least 10 characters'**
  String get please_enter_review;

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

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @areYouSureYouWantToDeleteAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications?'**
  String get areYouSureYouWantToDeleteAllNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @markAllAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark all as unread'**
  String get markAllAsUnread;

  /// No description provided for @markAllAsReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read successfully'**
  String get markAllAsReadSuccess;

  /// No description provided for @markAllAsUnreadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark all as unread successfully'**
  String get markAllAsUnreadSuccess;

  /// No description provided for @markAllAsReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read failed'**
  String get markAllAsReadFailed;

  /// No description provided for @markAllAsUnreadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark all as unread failed'**
  String get markAllAsUnreadFailed;

  /// No description provided for @deleteAllNotificationsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications successfully'**
  String get deleteAllNotificationsSuccess;

  /// No description provided for @deleteAllNotificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications failed'**
  String get deleteAllNotificationsFailed;

  /// No description provided for @markReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark read successfully'**
  String get markReadSuccess;

  /// No description provided for @markReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark read failed'**
  String get markReadFailed;

  /// No description provided for @markUnreadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark unread successfully'**
  String get markUnreadSuccess;

  /// No description provided for @markUnreadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark unread failed'**
  String get markUnreadFailed;

  /// No description provided for @deleteNotificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete notification successfully'**
  String get deleteNotificationSuccess;

  /// No description provided for @deleteNotificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete notification failed'**
  String get deleteNotificationFailed;

  /// No description provided for @markAsReadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark as read successfully'**
  String get markAsReadSuccess;

  /// No description provided for @markAsReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark as read failed'**
  String get markAsReadFailed;

  /// No description provided for @markAsUnreadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread successfully'**
  String get markAsUnreadSuccess;

  /// No description provided for @markAsUnreadFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread failed'**
  String get markAsUnreadFailed;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get deleteNotification;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @youHave.
  ///
  /// In en, this message translates to:
  /// **'You have'**
  String get youHave;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'unread notifications'**
  String get unreadNotifications;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @notificationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted successfully'**
  String get notificationDeletedSuccessfully;

  /// No description provided for @notificationDeletedFailed.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted failed'**
  String get notificationDeletedFailed;

  /// No description provided for @areYouSureYouWantToDeleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification?'**
  String get areYouSureYouWantToDeleteNotification;

  /// No description provided for @add_new_book_to_library.
  ///
  /// In en, this message translates to:
  /// **'Add new book to library'**
  String get add_new_book_to_library;

  /// No description provided for @please_upload_ebook_file_first.
  ///
  /// In en, this message translates to:
  /// **'Please upload ebook file first'**
  String get please_upload_ebook_file_first;

  /// No description provided for @book_has_been_added_to_local_library.
  ///
  /// In en, this message translates to:
  /// **'Book has been added to local library'**
  String get book_has_been_added_to_local_library;

  /// No description provided for @youWillReceiveNotificationsHere.
  ///
  /// In en, this message translates to:
  /// **'You will receive notifications here'**
  String get youWillReceiveNotificationsHere;

  /// No description provided for @reading_progress.
  ///
  /// In en, this message translates to:
  /// **'Reading progress'**
  String get reading_progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @continue_reading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continue_reading;

  /// No description provided for @start_reading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get start_reading;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @last_read.
  ///
  /// In en, this message translates to:
  /// **'Last read'**
  String get last_read;

  /// No description provided for @search_filter.
  ///
  /// In en, this message translates to:
  /// **'Search filter'**
  String get search_filter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @i_uploaded.
  ///
  /// In en, this message translates to:
  /// **'I uploaded'**
  String get i_uploaded;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @epub.
  ///
  /// In en, this message translates to:
  /// **'EPUB'**
  String get epub;

  /// No description provided for @pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get apply_filters;

  /// No description provided for @no_name.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get no_name;

  /// No description provided for @book_removed_from_library.
  ///
  /// In en, this message translates to:
  /// **'Book removed from library'**
  String get book_removed_from_library;

  /// No description provided for @no_books_found.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get no_books_found;

  /// No description provided for @no_book_found.
  ///
  /// In en, this message translates to:
  /// **'No book found'**
  String get no_book_found;

  /// No description provided for @unselect_all.
  ///
  /// In en, this message translates to:
  /// **'Unselect all'**
  String get unselect_all;

  /// No description provided for @select_all.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get select_all;

  /// No description provided for @use_select_file_to_browse_directory.
  ///
  /// In en, this message translates to:
  /// **'Use \'Select file\' to browse directory'**
  String get use_select_file_to_browse_directory;

  /// No description provided for @no_pdf_epub_mobi_found.
  ///
  /// In en, this message translates to:
  /// **'No PDF, EPUB, or MOBI found'**
  String get no_pdf_epub_mobi_found;

  /// No description provided for @find_book.
  ///
  /// In en, this message translates to:
  /// **'Find book'**
  String get find_book;

  /// No description provided for @search_book.
  ///
  /// In en, this message translates to:
  /// **'Search book'**
  String get search_book;

  /// No description provided for @select_all_books.
  ///
  /// In en, this message translates to:
  /// **'Select all books'**
  String get select_all_books;

  /// No description provided for @unselect_all_books.
  ///
  /// In en, this message translates to:
  /// **'Unselect all books'**
  String get unselect_all_books;

  /// No description provided for @scan_again.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scan_again;

  /// No description provided for @tap_or_long_press_to_select_file.
  ///
  /// In en, this message translates to:
  /// **'Tap on file to select or long press to select file'**
  String get tap_or_long_press_to_select_file;

  /// No description provided for @delete_book_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book?'**
  String get delete_book_confirmation_message;

  /// No description provided for @delete_book_success.
  ///
  /// In en, this message translates to:
  /// **'Book deleted successfully'**
  String get delete_book_success;

  /// No description provided for @delete_book_failed.
  ///
  /// In en, this message translates to:
  /// **'Book deleted failed'**
  String get delete_book_failed;

  /// No description provided for @edit_book_success.
  ///
  /// In en, this message translates to:
  /// **'Book edited successfully'**
  String get edit_book_success;

  /// No description provided for @edit_book_failed.
  ///
  /// In en, this message translates to:
  /// **'Book edited failed'**
  String get edit_book_failed;

  /// No description provided for @current_ebook_file_cannot_be_changed_from_this_screen.
  ///
  /// In en, this message translates to:
  /// **'Current ebook file cannot be changed from this screen.'**
  String get current_ebook_file_cannot_be_changed_from_this_screen;

  /// No description provided for @update_book_info.
  ///
  /// In en, this message translates to:
  /// **'Update book information'**
  String get update_book_info;

  /// No description provided for @update_book_success.
  ///
  /// In en, this message translates to:
  /// **'Book updated successfully!'**
  String get update_book_success;

  /// No description provided for @create_book_success.
  ///
  /// In en, this message translates to:
  /// **'Book created successfully!'**
  String get create_book_success;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get error_occurred;

  /// No description provided for @update_book.
  ///
  /// In en, this message translates to:
  /// **'Update book'**
  String get update_book;

  /// No description provided for @updating_book.
  ///
  /// In en, this message translates to:
  /// **'Updating book...'**
  String get updating_book;

  /// No description provided for @book_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Book deleted successfully'**
  String get book_deleted_successfully;

  /// No description provided for @error_deleting_book.
  ///
  /// In en, this message translates to:
  /// **'Error deleting book! Please try again later.'**
  String get error_deleting_book;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get go_back;

  /// No description provided for @file_type.
  ///
  /// In en, this message translates to:
  /// **'File type'**
  String get file_type;

  /// No description provided for @file_size.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get file_size;

  /// No description provided for @file_path.
  ///
  /// In en, this message translates to:
  /// **'File path'**
  String get file_path;

  /// No description provided for @reading_books.
  ///
  /// In en, this message translates to:
  /// **'Reading books'**
  String get reading_books;

  /// No description provided for @you_have_no_book_reading.
  ///
  /// In en, this message translates to:
  /// **'You have no book reading.'**
  String get you_have_no_book_reading;

  /// No description provided for @continue_reading_books.
  ///
  /// In en, this message translates to:
  /// **'Continue reading books'**
  String get continue_reading_books;

  /// No description provided for @continue_reading_books_description.
  ///
  /// In en, this message translates to:
  /// **'Continue reading books'**
  String get continue_reading_books_description;

  /// No description provided for @reading_time.
  ///
  /// In en, this message translates to:
  /// **'Reading time:'**
  String get reading_time;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @pdf_search_in_pdf.
  ///
  /// In en, this message translates to:
  /// **'Search in PDF...'**
  String get pdf_search_in_pdf;

  /// No description provided for @pdf_zoom_in_out.
  ///
  /// In en, this message translates to:
  /// **'Zoom in/out'**
  String get pdf_zoom_in_out;

  /// No description provided for @pdf_toolbar.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get pdf_toolbar;

  /// No description provided for @pdf_read_ebook.
  ///
  /// In en, this message translates to:
  /// **'Read ebook'**
  String get pdf_read_ebook;

  /// No description provided for @pdf_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdf_share;

  /// No description provided for @pdf_share_text.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\"is shared from Readbox. Download the app to read for free! 📚'**
  String pdf_share_text(String title);

  /// No description provided for @pdf_share_file_not_found.
  ///
  /// In en, this message translates to:
  /// **'File not found to share'**
  String get pdf_share_file_not_found;

  /// No description provided for @pdf_share_wait_download.
  ///
  /// In en, this message translates to:
  /// **'PDF is loading, please wait and try again'**
  String get pdf_share_wait_download;

  /// No description provided for @pdf_share_success.
  ///
  /// In en, this message translates to:
  /// **'Shared successfully'**
  String get pdf_share_success;

  /// No description provided for @pdf_share_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot share: {error}'**
  String pdf_share_error(String error);

  /// No description provided for @pdf_load_failed_retry.
  ///
  /// In en, this message translates to:
  /// **'PDF not loaded yet, try again later'**
  String get pdf_load_failed_retry;

  /// No description provided for @pdf_document_read_complete.
  ///
  /// In en, this message translates to:
  /// **'Document finished reading'**
  String get pdf_document_read_complete;

  /// No description provided for @pdf_page_of.
  ///
  /// In en, this message translates to:
  /// **'Page {current}/{total}'**
  String pdf_page_of(int current, int total);

  /// No description provided for @pdf_cannot_load.
  ///
  /// In en, this message translates to:
  /// **'Cannot load PDF'**
  String get pdf_cannot_load;

  /// No description provided for @pdf_view_file_info.
  ///
  /// In en, this message translates to:
  /// **'View file info'**
  String get pdf_view_file_info;

  /// No description provided for @pdf_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading PDF...'**
  String get pdf_loading;

  /// No description provided for @pdf_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pdf_please_wait;

  /// No description provided for @pdf_reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get pdf_reading;

  /// No description provided for @pdf_search_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get pdf_search_tooltip;

  /// No description provided for @pdf_jump_to_page.
  ///
  /// In en, this message translates to:
  /// **'Jump to page'**
  String get pdf_jump_to_page;

  /// No description provided for @pdf_page_number.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get pdf_page_number;

  /// No description provided for @pdf_go.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get pdf_go;

  /// No description provided for @pdf_invalid_page.
  ///
  /// In en, this message translates to:
  /// **'Invalid page number'**
  String get pdf_invalid_page;

  /// No description provided for @pdf_file_info.
  ///
  /// In en, this message translates to:
  /// **'PDF file info'**
  String get pdf_file_info;

  /// No description provided for @pdf_path_label.
  ///
  /// In en, this message translates to:
  /// **'Path:'**
  String get pdf_path_label;

  /// No description provided for @pdf_tts_read_error.
  ///
  /// In en, this message translates to:
  /// **'Read error: {error}'**
  String pdf_tts_read_error(String error);

  /// No description provided for @pdf_notes_list.
  ///
  /// In en, this message translates to:
  /// **'Notes list'**
  String get pdf_notes_list;

  /// No description provided for @pdf_add_note.
  ///
  /// In en, this message translates to:
  /// **'Add note'**
  String get pdf_add_note;

  /// No description provided for @pdf_add_note_description.
  ///
  /// In en, this message translates to:
  /// **'Add note description'**
  String get pdf_add_note_description;

  /// No description provided for @pdf_add_note_description_successfully.
  ///
  /// In en, this message translates to:
  /// **'Add note description successfully'**
  String get pdf_add_note_description_successfully;

  /// No description provided for @pdf_add_note_description_failed.
  ///
  /// In en, this message translates to:
  /// **'Add note description failed'**
  String get pdf_add_note_description_failed;

  /// No description provided for @pdf_drawings_saved.
  ///
  /// In en, this message translates to:
  /// **'Drawings saved'**
  String get pdf_drawings_saved;

  /// No description provided for @pdf_undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get pdf_undo;

  /// No description provided for @pdf_done_drawing.
  ///
  /// In en, this message translates to:
  /// **'Done drawing'**
  String get pdf_done_drawing;

  /// No description provided for @pdf_note_added.
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get pdf_note_added;

  /// No description provided for @pdf_note_added_successfully.
  ///
  /// In en, this message translates to:
  /// **'Note added successfully'**
  String get pdf_note_added_successfully;

  /// No description provided for @pdf_note_added_failed.
  ///
  /// In en, this message translates to:
  /// **'Note added failed'**
  String get pdf_note_added_failed;

  /// No description provided for @pdf_note_added_description.
  ///
  /// In en, this message translates to:
  /// **'Note added description'**
  String get pdf_note_added_description;

  /// No description provided for @pdf_note_added_description_successfully.
  ///
  /// In en, this message translates to:
  /// **'Note added description successfully'**
  String get pdf_note_added_description_successfully;

  /// No description provided for @pdf_note_added_description_failed.
  ///
  /// In en, this message translates to:
  /// **'Note added description failed'**
  String get pdf_note_added_description_failed;

  /// No description provided for @pdf_no_notes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get pdf_no_notes;

  /// No description provided for @pdf_note_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter note'**
  String get pdf_note_hint;

  /// No description provided for @tools_word_to_pdf.
  ///
  /// In en, this message translates to:
  /// **'Word to PDF'**
  String get tools_word_to_pdf;

  /// No description provided for @tools_word_to_pdf_description.
  ///
  /// In en, this message translates to:
  /// **'Convert Word documents to PDF'**
  String get tools_word_to_pdf_description;

  /// No description provided for @tools_document_scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get tools_document_scanner;

  /// No description provided for @tools_document_scanner_description.
  ///
  /// In en, this message translates to:
  /// **'Scan documents using camera'**
  String get tools_document_scanner_description;

  /// No description provided for @tools_select_word_file.
  ///
  /// In en, this message translates to:
  /// **'Select Word file'**
  String get tools_select_word_file;

  /// No description provided for @tools_converting.
  ///
  /// In en, this message translates to:
  /// **'Converting...'**
  String get tools_converting;

  /// No description provided for @tools_conversion_success.
  ///
  /// In en, this message translates to:
  /// **'Conversion successful'**
  String get tools_conversion_success;

  /// No description provided for @tools_conversion_failed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get tools_conversion_failed;

  /// No description provided for @tools_no_file_selected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get tools_no_file_selected;

  /// No description provided for @tools_scan_document.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get tools_scan_document;

  /// No description provided for @tools_add_word_file.
  ///
  /// In en, this message translates to:
  /// **'Add word file'**
  String get tools_add_word_file;

  /// No description provided for @tools_add_image_file.
  ///
  /// In en, this message translates to:
  /// **'Add image file'**
  String get tools_add_image_file;

  /// No description provided for @tools_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get tools_take_photo;

  /// No description provided for @tools_choose_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get tools_choose_from_gallery;

  /// No description provided for @tools_save_as_pdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get tools_save_as_pdf;

  /// No description provided for @tools_add_more_pages.
  ///
  /// In en, this message translates to:
  /// **'Add more pages'**
  String get tools_add_more_pages;

  /// No description provided for @tools_remove_page.
  ///
  /// In en, this message translates to:
  /// **'Remove page'**
  String get tools_remove_page;

  /// No description provided for @tools_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tools_preview;

  /// No description provided for @tools_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get tools_processing;

  /// No description provided for @tools_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get tools_saved_successfully;

  /// No description provided for @tools_save_failed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get tools_save_failed;

  /// No description provided for @tools_file_saved_to.
  ///
  /// In en, this message translates to:
  /// **'File saved to: {path}'**
  String tools_file_saved_to(String path);

  /// No description provided for @tools_pages_count.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String tools_pages_count(int count);

  /// No description provided for @tools_convert_to_pdf.
  ///
  /// In en, this message translates to:
  /// **'Convert to PDF'**
  String get tools_convert_to_pdf;

  /// No description provided for @tools_select_file_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a file first'**
  String get tools_select_file_first;

  /// No description provided for @need_permission_to_access_memory.
  ///
  /// In en, this message translates to:
  /// **'Need permission to access memory'**
  String get need_permission_to_access_memory;

  /// No description provided for @please_grant_permission_to_search_file.
  ///
  /// In en, this message translates to:
  /// **'Please grant permission to search file'**
  String get please_grant_permission_to_search_file;

  /// No description provided for @or_use_select_file_to_browse_directory_without_permission.
  ///
  /// In en, this message translates to:
  /// **'Or use \'Select file\' to browse directory (without permission)'**
  String get or_use_select_file_to_browse_directory_without_permission;

  /// No description provided for @grant_permission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get grant_permission;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'books'**
  String get books;

  /// No description provided for @to_library.
  ///
  /// In en, this message translates to:
  /// **'to library'**
  String get to_library;

  /// No description provided for @books_already_exist.
  ///
  /// In en, this message translates to:
  /// **'books already exist'**
  String get books_already_exist;

  /// No description provided for @error_selecting_file.
  ///
  /// In en, this message translates to:
  /// **'Error selecting file'**
  String get error_selecting_file;

  /// No description provided for @error_scanning_files.
  ///
  /// In en, this message translates to:
  /// **'Error scanning files'**
  String get error_scanning_files;

  /// No description provided for @scanning_in_memory.
  ///
  /// In en, this message translates to:
  /// **'Scanning in memory...'**
  String get scanning_in_memory;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get files;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @from_directory.
  ///
  /// In en, this message translates to:
  /// **'from directory'**
  String get from_directory;

  /// No description provided for @file_selected.
  ///
  /// In en, this message translates to:
  /// **'File selected'**
  String get file_selected;

  /// No description provided for @book_added_to_local_library.
  ///
  /// In en, this message translates to:
  /// **'Book added to local library'**
  String get book_added_to_local_library;

  /// No description provided for @find_word.
  ///
  /// In en, this message translates to:
  /// **'Find word file'**
  String get find_word;

  /// No description provided for @find_image.
  ///
  /// In en, this message translates to:
  /// **'Find image file'**
  String get find_image;

  /// No description provided for @no_word_file_found.
  ///
  /// In en, this message translates to:
  /// **'No file .docx found'**
  String get no_word_file_found;

  /// No description provided for @no_image_file_found.
  ///
  /// In en, this message translates to:
  /// **'No file .jpg, .jpeg, .png found'**
  String get no_image_file_found;

  /// No description provided for @no_file_found.
  ///
  /// In en, this message translates to:
  /// **'No file found'**
  String get no_file_found;

  /// No description provided for @tap_to_view.
  ///
  /// In en, this message translates to:
  /// **'Tap to view'**
  String get tap_to_view;

  /// No description provided for @please_authenticate_to_login.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to login'**
  String get please_authenticate_to_login;

  /// No description provided for @authentication_failed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authentication_failed;

  /// No description provided for @biometric_not_available_on_this_device.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available on this device'**
  String get biometric_not_available_on_this_device;

  /// No description provided for @biometric_not_enrolled.
  ///
  /// In en, this message translates to:
  /// **'Biometric not enrolled. Please set up in Settings'**
  String get biometric_not_enrolled;

  /// No description provided for @too_many_attempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get too_many_attempts;

  /// No description provided for @biometric_permanently_locked_out.
  ///
  /// In en, this message translates to:
  /// **'Biometric permanently locked out. Please use password'**
  String get biometric_permanently_locked_out;

  /// No description provided for @authentication_error.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authentication_error;

  /// No description provided for @biometric_not_enabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric not enabled'**
  String get biometric_not_enabled;

  /// No description provided for @no_login_info_saved.
  ///
  /// In en, this message translates to:
  /// **'No login info saved'**
  String get no_login_info_saved;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get login_error;

  /// No description provided for @biometric_not_supported_on_this_device.
  ///
  /// In en, this message translates to:
  /// **'Biometric not supported on this device'**
  String get biometric_not_supported_on_this_device;

  /// No description provided for @biometric_available.
  ///
  /// In en, this message translates to:
  /// **'Biometric available'**
  String get biometric_available;

  /// No description provided for @biometric_not_available.
  ///
  /// In en, this message translates to:
  /// **'Biometric not available'**
  String get biometric_not_available;

  /// No description provided for @verify_pin.
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get verify_pin;

  /// No description provided for @enter_pin_4_digits_sent_to_email.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN 4 digits sent to email'**
  String get enter_pin_4_digits_sent_to_email;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @clear_and_reenter.
  ///
  /// In en, this message translates to:
  /// **'Clear and reenter'**
  String get clear_and_reenter;

  /// No description provided for @resend_pin_in.
  ///
  /// In en, this message translates to:
  /// **'Resend pin in'**
  String get resend_pin_in;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @resend_pin.
  ///
  /// In en, this message translates to:
  /// **'Resend pin'**
  String get resend_pin;

  /// No description provided for @pin_resend_success.
  ///
  /// In en, this message translates to:
  /// **'PIN resend successfully'**
  String get pin_resend_success;

  /// No description provided for @verifying_pin.
  ///
  /// In en, this message translates to:
  /// **'Verifying pin...'**
  String get verifying_pin;

  /// No description provided for @authentication_success.
  ///
  /// In en, this message translates to:
  /// **'Authentication success'**
  String get authentication_success;

  /// No description provided for @delete_book_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete book \"{title}\" from library?'**
  String delete_book_confirmation(String title);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @cannot_load_pdf_description.
  ///
  /// In en, this message translates to:
  /// **'Cannot load PDF, please try again later or contact administrator for support.'**
  String get cannot_load_pdf_description;

  /// No description provided for @rate_and_review.
  ///
  /// In en, this message translates to:
  /// **'Rate & Review'**
  String get rate_and_review;

  /// No description provided for @rate_this_book.
  ///
  /// In en, this message translates to:
  /// **'Rate this book'**
  String get rate_this_book;

  /// No description provided for @your_rating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get your_rating;

  /// No description provided for @write_a_review.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get write_a_review;

  /// No description provided for @write_your_review_here.
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get write_your_review_here;

  /// No description provided for @submit_rating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submit_rating;

  /// No description provided for @rating_submitted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted successfully'**
  String get rating_submitted_successfully;

  /// No description provided for @rating_submission_failed.
  ///
  /// In en, this message translates to:
  /// **'Rating submission failed'**
  String get rating_submission_failed;

  /// No description provided for @please_select_rating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating'**
  String get please_select_rating;

  /// No description provided for @tap_to_rate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tap_to_rate;

  /// No description provided for @your_review.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get your_review;

  /// No description provided for @edit_review.
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get edit_review;

  /// No description provided for @delete_review.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get delete_review;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get no_reviews_yet;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @average_rating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get average_rating;

  /// No description provided for @total_ratings.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String total_ratings(int count);

  /// No description provided for @my_uploaded_books.
  ///
  /// In en, this message translates to:
  /// **'My uploaded books'**
  String get my_uploaded_books;

  /// No description provided for @subscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'Subscription plans'**
  String get subscriptionPlans;

  /// No description provided for @choosePlanDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a plan that fits your reading and storage needs.'**
  String get choosePlanDescription;

  /// No description provided for @noSubscriptionPlans.
  ///
  /// In en, this message translates to:
  /// **'No plans available at the moment.'**
  String get noSubscriptionPlans;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select plan'**
  String get selectPlan;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @storageLimit.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageLimit;

  /// No description provided for @ttsLimit.
  ///
  /// In en, this message translates to:
  /// **'Text-to-speech'**
  String get ttsLimit;

  /// No description provided for @convertLimit.
  ///
  /// In en, this message translates to:
  /// **'Word to PDF'**
  String get convertLimit;

  /// No description provided for @perPeriod.
  ///
  /// In en, this message translates to:
  /// **'per period'**
  String get perPeriod;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @useFree.
  ///
  /// In en, this message translates to:
  /// **'Use free'**
  String get useFree;

  /// No description provided for @viewAndManagePlans.
  ///
  /// In en, this message translates to:
  /// **'View and manage your plan'**
  String get viewAndManagePlans;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentResult.
  ///
  /// In en, this message translates to:
  /// **'Payment Result'**
  String get paymentResult;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;
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
