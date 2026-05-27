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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('vi')
  ];

  /// The name of the application
  ///
  /// In vi, this message translates to:
  /// **'SportBuddies'**
  String get appTitle;

  /// No description provided for @loginHeroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt sân\ntrong tích tắc.'**
  String get loginHeroTitle;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục tới SportBuddies để đặt sân và chơi cùng bạn bè.'**
  String get loginSubtitle;

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

  /// No description provided for @orDivider.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get orDivider;

  /// No description provided for @noAccountPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get noAccountPrompt;

  /// No description provided for @signUpNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get signUpNow;

  /// No description provided for @signUpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký miễn phí. Bạn sẽ nhận email xác minh sau khi tạo tài khoản.'**
  String get signUpSubtitle;

  /// No description provided for @labelFullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get labelFullName;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 8 ký tự, có chữ và số.'**
  String get passwordHint;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get labelConfirmPassword;

  /// No description provided for @signUpButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get signUpButton;

  /// No description provided for @signUpTerms.
  ///
  /// In vi, this message translates to:
  /// **'Bằng việc đăng ký, bạn đồng ý với Điều khoản và Chính sách của SportBuddies.'**
  String get signUpTerms;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra hộp thư của bạn'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi đã gửi liên kết xác minh đến {email}.\nMở email và bấm vào liên kết để kích hoạt tài khoản.'**
  String verifyEmailBody(String email);

  /// No description provided for @verifyEmailNotReceived.
  ///
  /// In vi, this message translates to:
  /// **'Không thấy email?'**
  String get verifyEmailNotReceived;

  /// No description provided for @verifyEmailTips.
  ///
  /// In vi, this message translates to:
  /// **'• Kiểm tra thư mục Spam / Quảng cáo\n• Đợi vài phút rồi thử lại\n• Đảm bảo bạn nhập đúng địa chỉ email'**
  String get verifyEmailTips;

  /// No description provided for @resendCooldown.
  ///
  /// In vi, this message translates to:
  /// **'Có thể gửi lại sau {timer}'**
  String resendCooldown(String timer);

  /// No description provided for @resendVerification.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại email xác minh'**
  String get resendVerification;

  /// No description provided for @backToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToLogin;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In vi, this message translates to:
  /// **'Nhập địa chỉ email bạn đã dùng để tạo tài khoản. Chúng tôi sẽ gửi liên kết đặt lại mật khẩu.'**
  String get forgotPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In vi, this message translates to:
  /// **'Gửi liên kết đặt lại mật khẩu'**
  String get sendResetLink;

  /// No description provided for @checkInboxTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra hộp thư'**
  String get checkInboxTitle;

  /// No description provided for @checkInboxBody.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn.'**
  String get checkInboxBody;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get profileTitle;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @languageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @errorFullNameEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên.'**
  String get errorFullNameEmpty;

  /// No description provided for @errorEmailEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email.'**
  String get errorEmailEmpty;

  /// No description provided for @errorPasswordWeak.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 8 ký tự, có chữ và số.'**
  String get errorPasswordWeak;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp.'**
  String get errorPasswordMismatch;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @nameEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa tên'**
  String get nameEditTitle;

  /// No description provided for @labelPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get labelPhone;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get profilePersonalInfo;

  /// No description provided for @profilePersonalInfoSub.
  ///
  /// In vi, this message translates to:
  /// **'Tên, ảnh đại diện, số điện thoại'**
  String get profilePersonalInfoSub;

  /// No description provided for @profileNotificationsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get profileNotificationsLabel;

  /// No description provided for @profileNotificationsLabelSub.
  ///
  /// In vi, this message translates to:
  /// **'Push, email, lời mời chơi'**
  String get profileNotificationsLabelSub;

  /// No description provided for @profileFavourites.
  ///
  /// In vi, this message translates to:
  /// **'Sân yêu thích'**
  String get profileFavourites;

  /// No description provided for @profilePlayTogether.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chơi cùng'**
  String get profilePlayTogether;

  /// No description provided for @profileReferral.
  ///
  /// In vi, this message translates to:
  /// **'Mời bạn, nhận miễn phí'**
  String get profileReferral;

  /// No description provided for @profileReferralSub.
  ///
  /// In vi, this message translates to:
  /// **'1 trận miễn phí cho mỗi lời mời'**
  String get profileReferralSub;

  /// No description provided for @profileHelpCenter.
  ///
  /// In vi, this message translates to:
  /// **'Trung tâm trợ giúp'**
  String get profileHelpCenter;

  /// No description provided for @profileTerms.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản & Chính sách'**
  String get profileTerms;

  /// No description provided for @profileActivitySection.
  ///
  /// In vi, this message translates to:
  /// **'HOẠT ĐỘNG'**
  String get profileActivitySection;

  /// No description provided for @profileSupportSection.
  ///
  /// In vi, this message translates to:
  /// **'HỖ TRỢ'**
  String get profileSupportSection;

  /// No description provided for @profileSignOut.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get profileSignOut;

  /// No description provided for @profileGamesCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} trận'**
  String profileGamesCount(int count);

  /// No description provided for @profileFavouritesCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} sân yêu thích'**
  String profileFavouritesCount(int count);
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
      'that was used.');
}
