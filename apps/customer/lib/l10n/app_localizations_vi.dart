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
  String get navMap => 'Khám phá';

  @override
  String get navBookings => 'Lịch đặt';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get navSlots => 'Slot trống';

  @override
  String get commonFilter => 'Bộ lọc';

  @override
  String get commonSearch => 'Tìm kiếm';

  @override
  String get commonNotifications => 'Thông báo';

  @override
  String get commonReset => 'Đặt lại';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get sportAll => 'Tất cả';

  @override
  String get sportFootball => 'Bóng đá';

  @override
  String get sportPickleball => 'Pickleball';

  @override
  String get sportBadminton => 'Cầu lông';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportMulti => 'Đa năng';

  @override
  String get sportGeneric => 'Thể thao';

  @override
  String availabilityOpenSlots(int count) {
    return '$count slot trống';
  }

  @override
  String get availabilityFull => 'Hết slot';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get distanceWithin5 => 'Trong 5 km';

  @override
  String get discoveryTitle => 'Khám phá';

  @override
  String get discoveryUpdating => 'Đang cập nhật…';

  @override
  String get discoveryNoMatch => 'Không có sân khớp bộ lọc';

  @override
  String discoverySubtitle(int count, int slots) {
    return '$count sân · $slots slot trống quanh đây';
  }

  @override
  String discoveryCourtsCount(int count) {
    return '$count sân';
  }

  @override
  String get discoverySortNearest => 'Gần nhất ↓';

  @override
  String get discoveryFooterEnd => 'Hết sân trong khoảng cách đã chọn';

  @override
  String get discoveryAllFullTitle => 'Tất cả sân quanh đây đang kín chỗ.';

  @override
  String get discoveryAllFullAction => 'Xem slot trống →';

  @override
  String get discoveryEmptyNoOpen => 'Không còn slot trống ở đây';

  @override
  String get discoveryEmptyNoCourts => 'Không tìm thấy sân nào';

  @override
  String get discoveryEmptyBody =>
      'Thử mở rộng khoảng cách hoặc bỏ bớt bộ lọc để xem thêm lựa chọn.';

  @override
  String get discoveryEmptyExpand => 'Mở rộng 5 km';

  @override
  String get discoveryEmptyResetFilters => 'Đặt lại bộ lọc';

  @override
  String get filterSports => 'Môn thể thao';

  @override
  String get filterDistance => 'Khoảng cách';

  @override
  String get filterStatus => 'Trạng thái';

  @override
  String get filterOnlyOpen => 'Chỉ hiển thị sân còn slot trống';

  @override
  String filterApply(int count) {
    return 'Hiển thị $count sân';
  }

  @override
  String get filterApplyZero => 'Xem kết quả · 0 sân';

  @override
  String get searchHint => 'Tìm sân, khu vực…';

  @override
  String searchAllCourts(int total) {
    return 'Tất cả $total sân · gần nhất trước';
  }

  @override
  String searchResultsFor(int count, String query) {
    return '$count kết quả cho \"$query\"';
  }

  @override
  String searchNoResults(String query) {
    return 'Không tìm thấy \"$query\"';
  }

  @override
  String get searchTryOther => 'Thử tên sân hoặc khu vực khác.';

  @override
  String get slotsTitle => 'Slot trống';

  @override
  String get slotsSubtitle => 'Slot đang tìm người chơi cùng';

  @override
  String slotsCountSort(int count) {
    return '$count slot · Sắp xếp: Sớm nhất ↓';
  }

  @override
  String get slotsHostInvite => 'Chủ slot mời chơi cùng';

  @override
  String get slotsOpenMatch => '🌐 Mở ghép';

  @override
  String get slotsFull => 'Đã đủ người';

  @override
  String slotsJoinedCount(int joined, int max) {
    return '$joined/$max người';
  }

  @override
  String get slotsEmptyTitle => 'Không có slot trống';

  @override
  String get slotsEmptyBody =>
      'Không có slot nào đang tìm người trong khu vực của bạn.';

  @override
  String get bookingValidationName => 'Vui lòng nhập họ tên';

  @override
  String get bookingValidationPhone => 'Vui lòng nhập số điện thoại';

  @override
  String get bookingValidationPhoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get bookingSlotTaken => 'Slot vừa được đặt, chọn giờ khác';

  @override
  String get bookingConfirmTitle => 'Xác nhận đặt sân';

  @override
  String bookingDurationHours(String hours) {
    return '$hours giờ';
  }

  @override
  String get bookingSelectedSlot => 'Khung giờ đã chọn';

  @override
  String bookingSlotCountDuration(String duration) {
    return '1 khung · $duration';
  }

  @override
  String get bookingTotalDuration => 'Tổng thời lượng';

  @override
  String get bookingRentPrice => 'Giá thuê';

  @override
  String bookingPricePerHour(String price) {
    return '$price/giờ';
  }

  @override
  String get bookingServiceFee => 'Phí dịch vụ';

  @override
  String get bookingFree => 'Miễn phí';

  @override
  String get bookingTotalPayment => 'Tổng thanh toán';

  @override
  String get bookingCashAtCourt => 'Thanh toán tiền mặt tại sân';

  @override
  String get bookingContactInfo => 'Thông tin liên hệ';

  @override
  String get bookingFieldName => 'Họ tên';

  @override
  String get bookingFieldPhone => 'Số điện thoại';

  @override
  String get bookingFieldNotes => 'Ghi chú cho chủ sân (tuỳ chọn)';

  @override
  String get bookingNotesHint => 'VD: cần mượn vợt, đến muộn 10p...';

  @override
  String get myBookingsTitle => 'Lịch đặt của tôi';

  @override
  String get bookingsTabUpcoming => 'Sắp tới';

  @override
  String get bookingsTabPending => 'Đang chờ';

  @override
  String get bookingsTabHistory => 'Lịch sử';

  @override
  String get bookingsFilterAll => 'Tất cả';

  @override
  String get bookingsFilterHost => 'Đặt sân';

  @override
  String get bookingsFilterJoin => 'Chơi ghép';

  @override
  String get bookingsFilterRecurring => '🔁 Định kỳ';

  @override
  String get bookingsFilterCompleted => 'Đã hoàn thành';

  @override
  String get bookingsEmptyUpcoming => 'Không có lịch đặt nào';

  @override
  String get bookingsEmptyPending => 'Không có lịch đang chờ';

  @override
  String get bookingsEmptyHistory => 'Không có lịch sử đặt sân';

  @override
  String get bookingsToday => 'HÔM NAY';

  @override
  String get bookingsTomorrow => 'NGÀY MAI';

  @override
  String get bookingsWeekdaySun => 'CHỦ NHẬT';

  @override
  String get bookingsWeekdayMon => 'THỨ HAI';

  @override
  String get bookingsWeekdayTue => 'THỨ BA';

  @override
  String get bookingsWeekdayWed => 'THỨ TƯ';

  @override
  String get bookingsWeekdayThu => 'THỨ NĂM';

  @override
  String get bookingsWeekdayFri => 'THỨ SÁU';

  @override
  String get bookingsWeekdaySat => 'THỨ BẢY';

  @override
  String get bookingsPendingHeader => 'ĐẶT SÂN CHỜ XÁC NHẬN';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get bookingsCancelTitle => 'Huỷ đặt sân này?';

  @override
  String get bookingsCancelBody => 'Hành động này không thể hoàn tác.';

  @override
  String get commonNo => 'Không';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String bookingsJoinedHost(String host) {
    return 'Bạn tham gia · chủ slot $host';
  }

  @override
  String bookingsHostWithPlayers(String players) {
    return 'Bạn là chủ slot · $players';
  }

  @override
  String get bookingsHost => 'Bạn là chủ slot';

  @override
  String get bookingsOneOff => 'Một lần';

  @override
  String bookingsExtraSlots(int count) {
    return '+$count khung';
  }

  @override
  String get bookingsLegendHost => 'Bạn đặt sân';

  @override
  String get bookingsLegendJoin => 'Bạn chơi ghép (tham gia slot)';

  @override
  String get bookingActionRebook => 'Đặt lại';

  @override
  String get bookingActionDetail => 'Chi tiết';

  @override
  String get bookingActionCancel => 'Huỷ';

  @override
  String get bookingStatusApproved => 'Đã duyệt';

  @override
  String get bookingStatusConfirmed => 'Đã xác nhận';

  @override
  String get bookingStatusPendingJoin => 'Chờ duyệt';

  @override
  String get bookingStatusPendingHost => 'Chờ xác nhận';

  @override
  String get bookingStatusCancelled => 'Đã huỷ';

  @override
  String get bookingJoinAccepted => 'Đã chấp nhận';

  @override
  String get bookingJoinRejected => 'Từ chối';
}
