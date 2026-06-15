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
    Locale('vi'),
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

  /// No description provided for @continueWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục với Google'**
  String get continueWithGoogle;

  /// No description provided for @signUpTerms.
  ///
  /// In vi, this message translates to:
  /// **'Bằng việc đăng ký, bạn đồng ý với Điều khoản và Chính sách của SportBuddies.'**
  String get signUpTerms;

  /// No description provided for @verifyEmailAppBarTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh email'**
  String get verifyEmailAppBarTitle;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra email để xác minh tài khoản'**
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

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc mật khẩu không đúng'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra email để xác minh tài khoản'**
  String get errorEmailNotConfirmed;

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

  /// No description provided for @errorAvatarFormat.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh đại diện phải thuộc định dạng JPEG hoặc PNG.'**
  String get errorAvatarFormat;

  /// No description provided for @errorAvatarSize.
  ///
  /// In vi, this message translates to:
  /// **'Dung lượng ảnh đại diện không được vượt quá 2 MB.'**
  String get errorAvatarSize;

  /// No description provided for @navMap.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get navMap;

  /// No description provided for @navBookings.
  ///
  /// In vi, this message translates to:
  /// **'Lịch đặt'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @navSlots.
  ///
  /// In vi, this message translates to:
  /// **'Slot trống'**
  String get navSlots;

  /// No description provided for @commonFilter.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get commonFilter;

  /// No description provided for @commonSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get commonSearch;

  /// No description provided for @commonNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get commonNotifications;

  /// No description provided for @commonReset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get commonReset;

  /// No description provided for @commonBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get commonBack;

  /// No description provided for @sportAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get sportAll;

  /// No description provided for @sportFootball.
  ///
  /// In vi, this message translates to:
  /// **'Bóng đá'**
  String get sportFootball;

  /// No description provided for @sportPickleball.
  ///
  /// In vi, this message translates to:
  /// **'Pickleball'**
  String get sportPickleball;

  /// No description provided for @sportBadminton.
  ///
  /// In vi, this message translates to:
  /// **'Cầu lông'**
  String get sportBadminton;

  /// No description provided for @sportTennis.
  ///
  /// In vi, this message translates to:
  /// **'Tennis'**
  String get sportTennis;

  /// No description provided for @sportMulti.
  ///
  /// In vi, this message translates to:
  /// **'Đa năng'**
  String get sportMulti;

  /// No description provided for @sportGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Thể thao'**
  String get sportGeneric;

  /// No description provided for @availabilityOpenSlots.
  ///
  /// In vi, this message translates to:
  /// **'{count} slot trống'**
  String availabilityOpenSlots(int count);

  /// No description provided for @availabilityFull.
  ///
  /// In vi, this message translates to:
  /// **'Hết slot'**
  String get availabilityFull;

  /// No description provided for @distanceKm.
  ///
  /// In vi, this message translates to:
  /// **'{km} km'**
  String distanceKm(String km);

  /// No description provided for @distanceWithin5.
  ///
  /// In vi, this message translates to:
  /// **'Trong 5 km'**
  String get distanceWithin5;

  /// No description provided for @discoveryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get discoveryTitle;

  /// No description provided for @discoveryUpdating.
  ///
  /// In vi, this message translates to:
  /// **'Đang cập nhật…'**
  String get discoveryUpdating;

  /// No description provided for @discoveryNoMatch.
  ///
  /// In vi, this message translates to:
  /// **'Không có sân khớp bộ lọc'**
  String get discoveryNoMatch;

  /// No description provided for @discoverySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'{count} sân · {slots} slot trống quanh đây'**
  String discoverySubtitle(int count, int slots);

  /// No description provided for @discoveryCourtsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} sân'**
  String discoveryCourtsCount(int count);

  /// No description provided for @discoverySortNearest.
  ///
  /// In vi, this message translates to:
  /// **'Gần nhất ↓'**
  String get discoverySortNearest;

  /// No description provided for @discoveryFooterEnd.
  ///
  /// In vi, this message translates to:
  /// **'Hết sân trong khoảng cách đã chọn'**
  String get discoveryFooterEnd;

  /// No description provided for @discoveryAllFullTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả sân quanh đây đang kín chỗ.'**
  String get discoveryAllFullTitle;

  /// No description provided for @discoveryAllFullAction.
  ///
  /// In vi, this message translates to:
  /// **'Xem slot trống →'**
  String get discoveryAllFullAction;

  /// No description provided for @discoveryEmptyNoOpen.
  ///
  /// In vi, this message translates to:
  /// **'Không còn slot trống ở đây'**
  String get discoveryEmptyNoOpen;

  /// No description provided for @discoveryEmptyNoCourts.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sân nào'**
  String get discoveryEmptyNoCourts;

  /// No description provided for @discoveryEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm lựa chọn.'**
  String get discoveryEmptyBody;

  /// No description provided for @discoveryEmptyExpand.
  ///
  /// In vi, this message translates to:
  /// **'Mở rộng 5 km'**
  String get discoveryEmptyExpand;

  /// No description provided for @discoveryEmptyResetFilters.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại bộ lọc'**
  String get discoveryEmptyResetFilters;

  /// No description provided for @filterSports.
  ///
  /// In vi, this message translates to:
  /// **'Môn thể thao'**
  String get filterSports;

  /// No description provided for @filterDistance.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách'**
  String get filterDistance;

  /// No description provided for @filterStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get filterStatus;

  /// No description provided for @filterOnlyOpen.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiển thị sân còn slot trống'**
  String get filterOnlyOpen;

  /// No description provided for @filterApply.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị {count} sân'**
  String filterApply(int count);

  /// No description provided for @filterApplyZero.
  ///
  /// In vi, this message translates to:
  /// **'Xem kết quả · 0 sân'**
  String get filterApplyZero;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm sân, khu vực…'**
  String get searchHint;

  /// No description provided for @searchAllCourts.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả {total} sân · gần nhất trước'**
  String searchAllCourts(int total);

  /// No description provided for @searchResultsFor.
  ///
  /// In vi, this message translates to:
  /// **'{count} kết quả cho \"{query}\"'**
  String searchResultsFor(int count, String query);

  /// No description provided for @searchNoResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchTryOther.
  ///
  /// In vi, this message translates to:
  /// **'Thử tên sân hoặc khu vực khác.'**
  String get searchTryOther;

  /// No description provided for @slotsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Slot trống'**
  String get slotsTitle;

  /// No description provided for @slotsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Slot đang tìm người chơi cùng'**
  String get slotsSubtitle;

  /// No description provided for @slotsCountSort.
  ///
  /// In vi, this message translates to:
  /// **'{count} slot · Sắp xếp: Sớm nhất ↓'**
  String slotsCountSort(int count);

  /// No description provided for @slotsHostInvite.
  ///
  /// In vi, this message translates to:
  /// **'Chủ slot mời chơi cùng'**
  String get slotsHostInvite;

  /// No description provided for @slotsOpenMatch.
  ///
  /// In vi, this message translates to:
  /// **'🌐 Mở ghép'**
  String get slotsOpenMatch;

  /// No description provided for @slotsFull.
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ người'**
  String get slotsFull;

  /// No description provided for @slotsJoinedCount.
  ///
  /// In vi, this message translates to:
  /// **'{joined}/{max} người'**
  String slotsJoinedCount(int joined, int max);

  /// No description provided for @slotsEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không có slot trống'**
  String get slotsEmptyTitle;

  /// No description provided for @slotsEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Không có slot nào đang tìm người trong khu vực của bạn.'**
  String get slotsEmptyBody;

  /// No description provided for @bookingValidationName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ tên'**
  String get bookingValidationName;

  /// No description provided for @bookingValidationPhone.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số điện thoại'**
  String get bookingValidationPhone;

  /// No description provided for @bookingValidationPhoneInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get bookingValidationPhoneInvalid;

  /// No description provided for @bookingSlotTaken.
  ///
  /// In vi, this message translates to:
  /// **'Slot vừa được đặt, chọn giờ khác'**
  String get bookingSlotTaken;

  /// No description provided for @bookingConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đặt sân'**
  String get bookingConfirmTitle;

  /// No description provided for @bookingDurationHours.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ'**
  String bookingDurationHours(String hours);

  /// No description provided for @bookingSelectedSlot.
  ///
  /// In vi, this message translates to:
  /// **'Khung giờ đã chọn'**
  String get bookingSelectedSlot;

  /// No description provided for @bookingSlotCountDuration.
  ///
  /// In vi, this message translates to:
  /// **'1 khung · {duration}'**
  String bookingSlotCountDuration(String duration);

  /// No description provided for @bookingTotalDuration.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thời lượng'**
  String get bookingTotalDuration;

  /// No description provided for @bookingRentPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê'**
  String get bookingRentPrice;

  /// No description provided for @bookingPricePerHour.
  ///
  /// In vi, this message translates to:
  /// **'{price}/giờ'**
  String bookingPricePerHour(String price);

  /// No description provided for @bookingServiceFee.
  ///
  /// In vi, this message translates to:
  /// **'Phí dịch vụ'**
  String get bookingServiceFee;

  /// No description provided for @bookingFree.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get bookingFree;

  /// No description provided for @bookingTotalPayment.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thanh toán'**
  String get bookingTotalPayment;

  /// No description provided for @bookingCashAtCourt.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán tiền mặt tại sân'**
  String get bookingCashAtCourt;

  /// No description provided for @bookingContactInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin liên hệ'**
  String get bookingContactInfo;

  /// No description provided for @bookingFieldName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get bookingFieldName;

  /// No description provided for @bookingFieldPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get bookingFieldPhone;

  /// No description provided for @bookingFieldNotes.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú cho chủ sân (tuỳ chọn)'**
  String get bookingFieldNotes;

  /// No description provided for @bookingNotesHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: cần mượn vợt, đến muộn 10p...'**
  String get bookingNotesHint;

  /// No description provided for @myBookingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch đặt của tôi'**
  String get myBookingsTitle;

  /// No description provided for @bookingsTabUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Sắp tới'**
  String get bookingsTabUpcoming;

  /// No description provided for @bookingsTabPending.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ'**
  String get bookingsTabPending;

  /// No description provided for @bookingsTabHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử'**
  String get bookingsTabHistory;

  /// No description provided for @bookingsFilterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get bookingsFilterAll;

  /// No description provided for @bookingsFilterHost.
  ///
  /// In vi, this message translates to:
  /// **'Đặt sân'**
  String get bookingsFilterHost;

  /// No description provided for @bookingsFilterJoin.
  ///
  /// In vi, this message translates to:
  /// **'Chơi ghép'**
  String get bookingsFilterJoin;

  /// No description provided for @bookingsFilterRecurring.
  ///
  /// In vi, this message translates to:
  /// **'🔁 Định kỳ'**
  String get bookingsFilterRecurring;

  /// No description provided for @bookingsFilterCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get bookingsFilterCompleted;

  /// No description provided for @bookingsEmptyUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Không có lịch đặt nào'**
  String get bookingsEmptyUpcoming;

  /// No description provided for @bookingsEmptyPending.
  ///
  /// In vi, this message translates to:
  /// **'Không có lịch đang chờ'**
  String get bookingsEmptyPending;

  /// No description provided for @bookingsEmptyHistory.
  ///
  /// In vi, this message translates to:
  /// **'Không có lịch sử đặt sân'**
  String get bookingsEmptyHistory;

  /// No description provided for @bookingsToday.
  ///
  /// In vi, this message translates to:
  /// **'HÔM NAY'**
  String get bookingsToday;

  /// No description provided for @bookingsTomorrow.
  ///
  /// In vi, this message translates to:
  /// **'NGÀY MAI'**
  String get bookingsTomorrow;

  /// No description provided for @bookingsWeekdaySun.
  ///
  /// In vi, this message translates to:
  /// **'CHỦ NHẬT'**
  String get bookingsWeekdaySun;

  /// No description provided for @bookingsWeekdayMon.
  ///
  /// In vi, this message translates to:
  /// **'THỨ HAI'**
  String get bookingsWeekdayMon;

  /// No description provided for @bookingsWeekdayTue.
  ///
  /// In vi, this message translates to:
  /// **'THỨ BA'**
  String get bookingsWeekdayTue;

  /// No description provided for @bookingsWeekdayWed.
  ///
  /// In vi, this message translates to:
  /// **'THỨ TƯ'**
  String get bookingsWeekdayWed;

  /// No description provided for @bookingsWeekdayThu.
  ///
  /// In vi, this message translates to:
  /// **'THỨ NĂM'**
  String get bookingsWeekdayThu;

  /// No description provided for @bookingsWeekdayFri.
  ///
  /// In vi, this message translates to:
  /// **'THỨ SÁU'**
  String get bookingsWeekdayFri;

  /// No description provided for @bookingsWeekdaySat.
  ///
  /// In vi, this message translates to:
  /// **'THỨ BẢY'**
  String get bookingsWeekdaySat;

  /// No description provided for @bookingsPendingHeader.
  ///
  /// In vi, this message translates to:
  /// **'ĐẶT SÂN CHỜ XÁC NHẬN'**
  String get bookingsPendingHeader;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @bookingsCancelTitle.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ đặt sân này?'**
  String get bookingsCancelTitle;

  /// No description provided for @bookingsCancelBody.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này không thể hoàn tác.'**
  String get bookingsCancelBody;

  /// No description provided for @commonNo.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get commonNo;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @bookingsJoinedHost.
  ///
  /// In vi, this message translates to:
  /// **'Bạn tham gia · chủ slot {host}'**
  String bookingsJoinedHost(String host);

  /// No description provided for @bookingsHostWithPlayers.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là chủ slot · {players}'**
  String bookingsHostWithPlayers(String players);

  /// No description provided for @bookingsHost.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là chủ slot'**
  String get bookingsHost;

  /// No description provided for @bookingsOneOff.
  ///
  /// In vi, this message translates to:
  /// **'Một lần'**
  String get bookingsOneOff;

  /// No description provided for @bookingsExtraSlots.
  ///
  /// In vi, this message translates to:
  /// **'+{count} khung'**
  String bookingsExtraSlots(int count);

  /// No description provided for @bookingsLegendHost.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đặt sân'**
  String get bookingsLegendHost;

  /// No description provided for @bookingsLegendJoin.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chơi ghép (tham gia slot)'**
  String get bookingsLegendJoin;

  /// No description provided for @bookingActionRebook.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get bookingActionRebook;

  /// No description provided for @bookingActionDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get bookingActionDetail;

  /// No description provided for @bookingActionCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get bookingActionCancel;

  /// No description provided for @bookingStatusApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get bookingStatusApproved;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusPendingJoin.
  ///
  /// In vi, this message translates to:
  /// **'Chờ duyệt'**
  String get bookingStatusPendingJoin;

  /// No description provided for @bookingStatusPendingHost.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận'**
  String get bookingStatusPendingHost;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã huỷ'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingJoinAccepted.
  ///
  /// In vi, this message translates to:
  /// **'Đã chấp nhận'**
  String get bookingJoinAccepted;

  /// No description provided for @bookingJoinRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get bookingJoinRejected;
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
