import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
/// import 'l10n/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// App title
  ///
  /// In vi, this message translates to:
  /// **'SnB · Bảng Điều Khiển Sân'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý sân của bạn với SportBuddies.'**
  String get loginSubtitle;

  /// No description provided for @loginHeroTagline.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý sân\nthông minh hơn.'**
  String get loginHeroTagline;

  /// No description provided for @loginHeroSub.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt đặt sân, xem lịch, theo dõi doanh thu — tất cả trong một nơi.'**
  String get loginHeroSub;

  /// No description provided for @labelEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get labelPassword;

  /// No description provided for @hintEmail.
  ///
  /// In vi, this message translates to:
  /// **'chusân@example.com'**
  String get hintEmail;

  /// No description provided for @hintPassword.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get hintPassword;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPasswordQuestion;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email tài khoản của bạn. Chúng tôi sẽ gửi link đặt lại mật khẩu.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi link đặt lại'**
  String get sendResetLinkButton;

  /// No description provided for @backToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToLogin;

  /// No description provided for @resetLinkSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi link đặt lại mật khẩu đến email của bạn.'**
  String get resetLinkSent;

  /// No description provided for @errorFieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập trường này.'**
  String get errorFieldRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ.'**
  String get errorInvalidEmail;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc mật khẩu không đúng.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNotOwner.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này không có quyền truy cập vào bảng điều khiển chủ sân.'**
  String get errorNotOwner;

  /// No description provided for @errorGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi. Vui lòng thử lại.'**
  String get errorGeneric;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navRequests.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu'**
  String get navRequests;

  /// No description provided for @navSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sân'**
  String get navSchedule;

  /// No description provided for @navFixed.
  ///
  /// In vi, this message translates to:
  /// **'Lịch cố định'**
  String get navFixed;

  /// No description provided for @navAnalytics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get navAnalytics;

  /// No description provided for @navPlayers.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get navPlayers;

  /// No description provided for @navNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt sân'**
  String get navSettings;

  /// No description provided for @navSupport.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ'**
  String get navSupport;

  /// No description provided for @navLogout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get navLogout;

  /// No description provided for @sectionManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý'**
  String get sectionManagement;

  /// No description provided for @sectionSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get sectionSystem;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này đang được phát triển.'**
  String get comingSoon;

  /// No description provided for @errorDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi không xác định'**
  String get errorDialogTitle;

  /// No description provided for @errorDialogClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get errorDialogClose;
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
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
