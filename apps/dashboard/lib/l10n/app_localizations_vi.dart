// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'SnB · Bảng Điều Khiển Sân';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginSubtitle => 'Quản lý sân của bạn với SportBuddies.';

  @override
  String get loginHeroTagline => 'Quản lý sân\nthông minh hơn.';

  @override
  String get loginHeroSub =>
      'Duyệt đặt sân, xem lịch, theo dõi doanh thu — tất cả trong một nơi.';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Mật khẩu';

  @override
  String get hintEmail => 'chusân@example.com';

  @override
  String get hintPassword => 'Nhập mật khẩu';

  @override
  String get forgotPasswordQuestion => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get forgotPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email tài khoản của bạn. Chúng tôi sẽ gửi link đặt lại mật khẩu.';

  @override
  String get sendResetLinkButton => 'Gửi link đặt lại';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get resetLinkSent => 'Đã gửi link đặt lại mật khẩu đến email của bạn.';

  @override
  String get errorFieldRequired => 'Vui lòng nhập trường này.';

  @override
  String get errorInvalidEmail => 'Email không hợp lệ.';

  @override
  String get errorInvalidCredentials => 'Email hoặc mật khẩu không đúng.';

  @override
  String get errorNotOwner =>
      'Tài khoản này không có quyền truy cập vào bảng điều khiển chủ sân.';

  @override
  String get errorGeneric => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navRequests => 'Yêu cầu';

  @override
  String get navSchedule => 'Lịch sân';

  @override
  String get navFixed => 'Lịch cố định';

  @override
  String get navAnalytics => 'Thống kê';

  @override
  String get navPlayers => 'Khách hàng';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get navSettings => 'Cài đặt sân';

  @override
  String get navSupport => 'Hỗ trợ';

  @override
  String get navLogout => 'Đăng xuất';

  @override
  String get sectionManagement => 'Quản lý';

  @override
  String get sectionSystem => 'Hệ thống';

  @override
  String get comingSoon => 'Tính năng này đang được phát triển.';

  @override
  String get errorDialogTitle => 'Lỗi không xác định';

  @override
  String get errorDialogClose => 'Đóng';
}
