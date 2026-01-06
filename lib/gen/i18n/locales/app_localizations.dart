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
