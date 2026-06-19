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

  @override
  String get commonClose => 'Đóng';

  @override
  String get weekdayMonday => 'Thứ hai';

  @override
  String get weekdayTuesday => 'Thứ ba';

  @override
  String get weekdayWednesday => 'Thứ tư';

  @override
  String get weekdayThursday => 'Thứ năm';

  @override
  String get weekdayFriday => 'Thứ sáu';

  @override
  String get weekdaySaturday => 'Thứ bảy';

  @override
  String get weekdaySunday => 'Chủ nhật';

  @override
  String get wizardStepConfirm => 'Xác nhận';

  @override
  String get wizardStepPlay => 'Chơi ghép';

  @override
  String get wizardStepAwait => 'Chờ duyệt';

  @override
  String get wizardStepDone => 'Hoàn tất';

  @override
  String get wizardStepPlayTitle => 'Chơi cùng ai?';

  @override
  String get wizardStepAwaitingTitle => 'Đang chờ xác nhận';

  @override
  String get wizardSkip => 'Bỏ qua';

  @override
  String get wizardSaveContinue => 'Lưu & tiếp tục';

  @override
  String get wizardViewBookings => 'Xem lịch đặt';

  @override
  String get wizardBackToMap => 'Về bản đồ';

  @override
  String get wizardRaceLost => 'Slot vừa được đặt';

  @override
  String get wizardNetworkFailed => 'Không thể đặt sân, thử lại';

  @override
  String get wizardTotalRent => 'Tổng giá thuê';

  @override
  String get wizardContactHint => 'Thông tin được gửi tới chủ sân.';

  @override
  String get wizardAdjacent => 'liền kề';

  @override
  String get wizardAnd => 'và';

  @override
  String wizardMergeNotice(String names, String duration) {
    return 'Khung $names liền nhau sẽ được gộp thành 1 buổi chơi $duration.';
  }

  @override
  String wizardSelectedSlots(int count) {
    return 'Đã chọn $count khung giờ';
  }

  @override
  String get wizardPickPlayers =>
      'Chọn ai chơi cùng trước khi gửi yêu cầu tới chủ sân.';

  @override
  String get wizardWhoCanJoin => 'Ai có thể tham gia?';

  @override
  String wizardAccessApplies(int count) {
    return 'Cài đặt áp dụng cho cả $count khung giờ đã đặt. Bạn có thể đổi riêng từng khung sau khi đặt xong.';
  }

  @override
  String get wizardPrivate => '🔒 Riêng tư';

  @override
  String get wizardPrivateDesc =>
      'Chỉ bạn và những người bạn mời mới chơi được.';

  @override
  String get wizardOpen => '🌐 Mở chơi ghép';

  @override
  String get wizardOpenDesc =>
      'Slot xuất hiện trong \"Slot trống\". Bạn duyệt yêu cầu tham gia.';

  @override
  String get wizardMaxPlayers => 'Số người tối đa';

  @override
  String get wizardDecrease => 'Giảm số người';

  @override
  String get wizardIncrease => 'Tăng số người';

  @override
  String get wizardMaxPlayersHint =>
      'Bao gồm cả bạn. Khuyến nghị 4 cho pickleball đôi.';

  @override
  String get wizardDeclinedTitle => 'Chủ sân không thể nhận';

  @override
  String get wizardWaitingTitle => 'Chờ chủ sân xác nhận';

  @override
  String get wizardDeclinedBody =>
      'Rất tiếc, chủ sân không thể nhận yêu cầu này. Bạn có thể chọn khung giờ khác.';

  @override
  String wizardWaitingBody(int count, String court) {
    return 'Yêu cầu đặt $count khung giờ đã được gửi tới $court. Chủ sân thường phản hồi trong vòng vài phút. Bạn sẽ nhận thông báo ngay khi có kết quả.';
  }

  @override
  String get wizardNotConfirmed => 'Yêu cầu chưa được xác nhận.';

  @override
  String get wizardPickAnotherTime => 'Chọn giờ khác';

  @override
  String get wizardBookingId => 'Mã đặt sân';

  @override
  String wizardCourtSlots(String court, int count) {
    return '$court · $count khung giờ';
  }

  @override
  String get wizardTimelineSent => 'Bạn gửi yêu cầu đặt sân';

  @override
  String get wizardTimelineDeclined => 'Chủ sân đã từ chối';

  @override
  String get wizardTimelineWaiting => 'Chờ chủ sân phản hồi...';

  @override
  String get wizardWaitingShort => 'đang chờ';

  @override
  String get wizardTimelineConfirmed => 'Đặt sân được xác nhận';

  @override
  String get wizardAwaitingSemantic => 'Đang chờ chủ sân xác nhận';

  @override
  String get wizardSuccessTitle => 'Đặt sân thành công!';

  @override
  String wizardSuccessBody(String court) {
    return 'Hẹn gặp bạn tại $court.\nĐến đúng giờ và mang theo tiền mặt nhé.';
  }

  @override
  String get wizardBringCash => 'Nhớ mang tiền mặt';

  @override
  String wizardBringCashBody(String total, int count) {
    return 'Thanh toán $total tại sân khi đến chơi (cho cả $count khung).';
  }

  @override
  String get wizardLabelCourt => 'Sân';

  @override
  String get wizardLabelDate => 'Ngày';

  @override
  String get wizardLabelSlots => 'Khung giờ';

  @override
  String get wizardLabelTotal => 'Tổng';

  @override
  String wizardMergedSuffix(int count) {
    return ' (gộp $count khung)';
  }

  @override
  String wizardHours(String value) {
    return '$value giờ';
  }

  @override
  String wizardSlotCountDuration(int count, String duration) {
    return '$count khung · $duration';
  }

  @override
  String get courtDetailBookCta => 'Chọn giờ trống & đặt sân';

  @override
  String get courtDetailOpenSlotsHelper =>
      'Tham gia cùng người chơi khác tại sân này';

  @override
  String courtDetailPhoto(int index, int total) {
    return 'ảnh sân · $index/$total';
  }

  @override
  String get courtDetailFavorite => 'Yêu thích';

  @override
  String get courtDetailShare => 'Chia sẻ';

  @override
  String courtDetailReviews(int count) {
    return '$count đánh giá';
  }

  @override
  String get courtDetailPricePerHour => 'Giá / giờ';

  @override
  String get courtDetailOpenToday => 'Slot trống hôm nay';

  @override
  String courtDetailSlotCount(int count) {
    return '$count slot';
  }

  @override
  String get courtDetailAmenities => 'Tiện ích';

  @override
  String get courtDetailAbout => 'Giới thiệu';

  @override
  String get courtDetailScheduleTitle => 'Lịch tổng hợp';

  @override
  String get courtDetailViewAllCourts => 'Xem lịch tất cả các sân';

  @override
  String get courtDetailScheduleSubtitle => 'Chọn khung giờ & đặt sân';

  @override
  String get slotPickerTitle => 'Chọn giờ';

  @override
  String get slotPickerDirectionsSoon => 'Chỉ đường — sắp ra mắt';

  @override
  String get slotPickerMultiHint => 'Chạm để chọn nhiều khung';

  @override
  String slotPickerOpenCount(int count) {
    return '$count slot trống · có thể đặt liên tiếp';
  }

  @override
  String get slotPickerOpenHelper => 'Chạm để xem chi tiết & xin chơi cùng';

  @override
  String slotPickerDistanceDrive(String km) {
    return '$km km · ~6 phút lái xe';
  }

  @override
  String get slotPickerDirections => 'Chỉ đường';

  @override
  String get slotPickerBooked => 'Đã đặt';

  @override
  String get slotPickerClosed => 'Đóng';

  @override
  String get slotPickerNoSelection => 'Chưa chọn khung';

  @override
  String slotPickerSelectedCount(int count, String duration) {
    return '$count khung đã chọn · $duration';
  }

  @override
  String slotPickerContinue(int count) {
    return 'Tiếp tục · $count khung';
  }

  @override
  String get slotPickerPickSlots => 'Chọn khung giờ';

  @override
  String get scheduleTitle => 'Lịch sân';

  @override
  String get scheduleAllCourts => 'Lịch tất cả các sân';

  @override
  String get scheduleToday => 'Hôm nay';

  @override
  String get scheduleDateWord => 'Ngày';

  @override
  String get scheduleBookedShort => 'Đặt';

  @override
  String get scheduleLegendOpen => 'Còn trống';

  @override
  String get scheduleLegendSelected => 'Đang chọn';

  @override
  String scheduleSelectedCount(int count) {
    return 'Đang chọn · $count khung';
  }

  @override
  String get scheduleClearAll => 'Xoá tất cả';

  @override
  String get scheduleContinue => 'Tiếp tục đặt sân';

  @override
  String get paymentTime => 'Thời gian';

  @override
  String paymentCashBody(String total) {
    return 'Thanh toán $total tại sân khi đến chơi.';
  }

  @override
  String get awaitingBody =>
      'Yêu cầu đặt sân đã được gửi đến chủ sân.\nBạn sẽ được thông báo khi có kết quả.';

  @override
  String get accessSlotSelected => 'Đã chọn khung giờ';

  @override
  String get accessApplies =>
      'Cài đặt áp dụng cho khung giờ đã đặt. Bạn có thể đổi sau khi đặt xong.';

  @override
  String get accessSlotTakenTitle => 'Khung giờ đã được đặt';

  @override
  String get accessSlotTakenBody =>
      'Rất tiếc, có người vừa đặt khung giờ này trước bạn.\nVui lòng chọn khung giờ khác.';

  @override
  String get bookingDetailTitle => 'Chi tiết đặt sân';

  @override
  String get bookingDetailMode => 'Chế độ';

  @override
  String get bookingDetailCallOwner => 'Gọi chủ sân';

  @override
  String get bookingDetailPlayers => 'Người chơi';

  @override
  String get bookingDetailInvite => '+ Mời bạn';

  @override
  String get bookingDetailYouHost => 'Bạn (chủ slot)';

  @override
  String get bookingDetailHostRole => 'Chủ slot';

  @override
  String bookingDetailAcceptedAt(String time) {
    return 'Đã chấp nhận · $time';
  }

  @override
  String get bookingDetailJoinRequests => 'Yêu cầu tham gia';

  @override
  String bookingDetailNewCount(int count) {
    return '$count mới';
  }

  @override
  String get bookingDetailNoRequests => 'Chưa có yêu cầu tham gia';

  @override
  String get bookingDetailAccept => 'Chấp nhận';

  @override
  String get bookingDetailManagePlayers => 'Quản lý người chơi';

  @override
  String get courtDetailOpenAddressIn => 'Mở địa chỉ bằng';

  @override
  String get courtDetailAppleMaps => 'Apple Maps';

  @override
  String get courtDetailGoogleMaps => 'Google Maps';

  @override
  String get courtDetailMapsUnavailable => 'Không mở được ứng dụng bản đồ';

  @override
  String get courtsOpenMatchSlots => 'Slot mở chơi ghép';

  @override
  String get courtsPriceFrom => 'Từ';

  @override
  String get courtsPerHourSuffix => '/giờ';

  @override
  String get courtsBookNow => 'Đặt sân ngay';

  @override
  String get courtsSoldOutToday => 'Hết slot hôm nay';

  @override
  String get courtsViewUpcoming => 'Xem lịch trống những ngày tới';

  @override
  String courtsSlotsLeft(int count) {
    return '· còn $count';
  }

  @override
  String get courtsJoin => 'Tham gia';

  @override
  String get courtsTomorrow => 'Mai';

  @override
  String get scheduleTapHint => 'Chạm vào ô trống để chọn khung giờ';

  @override
  String get scheduleMultiHint =>
      'Có thể chọn nhiều khung liên tục để đặt lâu hơn.';

  @override
  String get schedulePickAtLeastOne => 'Chọn ít nhất 1 khung giờ để tiếp tục';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get slotPickerTapSelect => 'Chạm để chọn';

  @override
  String get slotPickerNoSlotsToday =>
      'Không có khung giờ trống trong ngày này.';

  @override
  String get slotPickerLocked => 'Đã khoá';

  @override
  String get slotPickerMaintenance => 'Bảo trì';

  @override
  String get slotPickerBookNow => 'Đặt ngay';

  @override
  String get courtsDefaultName => 'Sân thể thao';

  @override
  String get notifTitle => 'Thông báo';

  @override
  String get notifMarkAllRead => 'Đọc tất cả';

  @override
  String get notifFilterAll => 'Tất cả';

  @override
  String get notifFilterBooking => 'Đặt sân';

  @override
  String get notifFilterPlayTogether => 'Chơi ghép';

  @override
  String get notifFilterReminder => 'Nhắc nhở';

  @override
  String get notifSectionToday => 'HÔM NAY';

  @override
  String get notifSectionYesterday => 'HÔM QUA';

  @override
  String get notifSectionOlder => 'TRƯỚC ĐÓ';

  @override
  String get notifEmpty => 'Không có thông báo';

  @override
  String notifEmptyInCategory(String filter) {
    return 'trong mục $filter';
  }

  @override
  String get notifJoinApproved => 'Đã duyệt';

  @override
  String get notifJoinRejected => 'Đã từ chối';

  @override
  String get notifActionReject => 'Từ chối';

  @override
  String get notifActionApprove => 'Duyệt';

  @override
  String get notifTimeJustNow => 'Vừa xong';

  @override
  String notifTimeMinutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String notifTimeHoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String notifTimeYesterdayAt(String time) {
    return 'Hôm qua, $time';
  }

  @override
  String notifTimeDaysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get slotsManageTitle => 'Quản lý người chơi';

  @override
  String get slotDetailTitle => 'Chi tiết slot';

  @override
  String get slotsPlayers => 'Người chơi';

  @override
  String get slotsHostRole => 'Chủ slot';

  @override
  String slotsPlayersFraction(int filled, int max) {
    return '$filled/$max người';
  }

  @override
  String get slotsJoinRequestsTitle => 'Yêu cầu tham gia';

  @override
  String get slotsAllRequestsHandled => 'Đã xử lý hết yêu cầu';

  @override
  String slotsSlotFullRemoveOne(int max) {
    return 'Slot đã đủ $max người. Gỡ một người để chấp nhận thêm.';
  }

  @override
  String get slotsReject => 'Từ chối';

  @override
  String get slotsAccept => 'Chấp nhận';

  @override
  String slotsGamesPlayed(int count) {
    return '$count trận';
  }

  @override
  String get slotsSeeListBelow => 'Xem danh sách bên dưới';

  @override
  String get slotsViewMap => 'Xem bản đồ';

  @override
  String get slotsHostMessageTitle => 'LỜI NHẮN TỪ CHỦ SLOT';

  @override
  String get slotsTimeSection => 'THỜI GIAN';

  @override
  String slotsHoursLabel(String hours) {
    return '$hours giờ';
  }

  @override
  String get slotsFullTryOther =>
      'Slot đã đầy. Hãy thử slot khác cùng giờ ở khu vực của bạn.';

  @override
  String slotsSpotsLeftLevel(int count) {
    return 'Còn $count chỗ trống · Cấp độ trung bình';
  }

  @override
  String get slotsEmptySpot => 'Chỗ trống';

  @override
  String slotsPlayerN(int n) {
    return 'Người chơi $n';
  }

  @override
  String get slotsRegisterToJoin => 'Đăng ký chơi cùng';

  @override
  String get slotsRequestSentPending => 'Đã gửi yêu cầu · Chờ duyệt';

  @override
  String get slotsJoined => 'Đã tham gia';

  @override
  String get slotsRequestRejected => 'Yêu cầu bị từ chối';

  @override
  String get sportBasketball => 'Bóng rổ';

  @override
  String get browseOpenMatchSlots => 'Slot mở chơi ghép';

  @override
  String browseSlotsLeft(int count) {
    return 'còn $count';
  }

  @override
  String get browseJoin => 'Tham gia';

  @override
  String bookingTileSession(int n, int total) {
    return 'Buổi $n / $total';
  }

  @override
  String get bookingStatusCompleted => 'Hoàn thành';

  @override
  String get bookingTypeRecurring => 'Định kỳ';

  @override
  String get bookingTypeOneTime => 'Một lần';

  @override
  String get bookingCancelConfirmTitle => 'Huỷ đặt sân này?';
}
