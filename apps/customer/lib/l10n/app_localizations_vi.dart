// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'SportBuddies';

  @override
  String get loginHeroTitle => 'Đặt sân\ntrong tích tắc.';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginSubtitle =>
      'Tiếp tục tới SportBuddies để đặt sân và chơi cùng bạn bè.';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Mật khẩu';

  @override
  String get forgotPasswordQuestion => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get orDivider => 'hoặc';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản?';

  @override
  String get signUpNow => 'Đăng ký ngay';

  @override
  String get signUpTitle => 'Tạo tài khoản';

  @override
  String get signUpSubtitle =>
      'Đăng ký miễn phí. Bạn sẽ nhận email xác minh sau khi tạo tài khoản.';

  @override
  String get labelFullName => 'Họ và tên';

  @override
  String get passwordHint => 'Tối thiểu 8 ký tự, có chữ và số.';

  @override
  String get labelConfirmPassword => 'Nhập lại mật khẩu';

  @override
  String get signUpButton => 'Tạo tài khoản';

  @override
  String get continueWithGoogle => 'Tiếp tục với Google';

  @override
  String get signUpTerms =>
      'Bằng việc đăng ký, bạn đồng ý với Điều khoản và Chính sách của SportBuddies.';

  @override
  String get verifyEmailAppBarTitle => 'Xác minh email';

  @override
  String get verifyEmailTitle =>
      'Vui lòng kiểm tra email để xác minh tài khoản';

  @override
  String verifyEmailBody(String email) {
    return 'Chúng tôi đã gửi liên kết xác minh đến $email.\nMở email và bấm vào liên kết để kích hoạt tài khoản.';
  }

  @override
  String get verifyEmailNotReceived => 'Không thấy email?';

  @override
  String get verifyEmailTips =>
      '• Kiểm tra thư mục Spam / Quảng cáo\n• Đợi vài phút rồi thử lại\n• Đảm bảo bạn nhập đúng địa chỉ email';

  @override
  String resendCooldown(String timer) {
    return 'Có thể gửi lại sau $timer';
  }

  @override
  String get resendVerification => 'Gửi lại email xác minh';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordBody =>
      'Nhập địa chỉ email bạn đã dùng để tạo tài khoản. Chúng tôi sẽ gửi liên kết đặt lại mật khẩu.';

  @override
  String get sendResetLink => 'Gửi liên kết đặt lại mật khẩu';

  @override
  String get checkInboxTitle => 'Kiểm tra hộp thư';

  @override
  String get checkInboxBody =>
      'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến email của bạn.';

  @override
  String get profileTitle => 'Tài khoản';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorFullNameEmpty => 'Vui lòng nhập họ và tên.';

  @override
  String get errorEmailEmpty => 'Vui lòng nhập email.';

  @override
  String get errorPasswordWeak => 'Tối thiểu 8 ký tự, có chữ và số.';

  @override
  String get errorPasswordMismatch => 'Mật khẩu không khớp.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không đúng';

  @override
  String get errorEmailNotConfirmed =>
      'Vui lòng kiểm tra email để xác minh tài khoản';

  @override
  String get save => 'Lưu';

  @override
  String get nameEditTitle => 'Chỉnh sửa tên';

  @override
  String get labelPhone => 'Số điện thoại';

  @override
  String get profilePersonalInfo => 'Thông tin cá nhân';

  @override
  String get profilePersonalInfoSub => 'Tên, ảnh đại diện, số điện thoại';

  @override
  String get profileNotificationsLabel => 'Thông báo';

  @override
  String get profileNotificationsLabelSub => 'Push, email, lời mời chơi';

  @override
  String get profileFavourites => 'Sân yêu thích';

  @override
  String get profilePlayTogether => 'Bạn chơi cùng';

  @override
  String get profileReferral => 'Mời bạn, nhận miễn phí';

  @override
  String get profileReferralSub => '1 trận miễn phí cho mỗi lời mời';

  @override
  String get profileHelpCenter => 'Trung tâm trợ giúp';

  @override
  String get profileTerms => 'Điều khoản & Chính sách';

  @override
  String get profileActivitySection => 'HOẠT ĐỘNG';

  @override
  String get profileSupportSection => 'HỖ TRỢ';

  @override
  String get profileSignOut => 'Đăng xuất';

  @override
  String profileGamesCount(int count) {
    return '$count trận';
  }

  @override
  String profileFavouritesCount(int count) {
    return '$count sân yêu thích';
  }

  @override
  String get errorAvatarFormat =>
      'Ảnh đại diện phải thuộc định dạng JPEG hoặc PNG.';

  @override
  String get errorAvatarSize =>
      'Dung lượng ảnh đại diện không được vượt quá 2 MB.';

  @override
  String get navMap => 'Bản đồ';

  @override
  String get navBookings => 'Lịch đặt';

  @override
  String get navProfile => 'Hồ sơ';
}
