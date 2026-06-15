// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SportBuddies';

  @override
  String get loginHeroTitle => 'Book courts\nin seconds.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle =>
      'Continue to SportBuddies to book courts and play with friends.';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get forgotPasswordQuestion => 'Forgot password?';

  @override
  String get loginButton => 'Sign in';

  @override
  String get orDivider => 'or';

  @override
  String get noAccountPrompt => 'Don\'t have an account?';

  @override
  String get signUpNow => 'Sign up now';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signUpSubtitle =>
      'Free to join. You\'ll receive a verification email after signing up.';

  @override
  String get labelFullName => 'Full name';

  @override
  String get passwordHint => 'Minimum 8 characters, letters and numbers.';

  @override
  String get labelConfirmPassword => 'Confirm password';

  @override
  String get signUpButton => 'Create account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signUpTerms =>
      'By signing up, you agree to SportBuddies\' Terms and Privacy Policy.';

  @override
  String get verifyEmailAppBarTitle => 'Verify email';

  @override
  String get verifyEmailTitle =>
      'Please check your email to verify your account';

  @override
  String verifyEmailBody(String email) {
    return 'We sent a verification link to $email.\nOpen the email and click the link to activate your account.';
  }

  @override
  String get verifyEmailNotReceived => 'Didn\'t receive the email?';

  @override
  String get verifyEmailTips =>
      '• Check your Spam / Promotions folder\n• Wait a few minutes and try again\n• Make sure you entered the correct email address';

  @override
  String resendCooldown(String timer) {
    return 'Resend available in $timer';
  }

  @override
  String get resendVerification => 'Resend verification email';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordBody =>
      'Enter the email you used to create your account. We\'ll send you a password reset link.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get checkInboxTitle => 'Check your inbox';

  @override
  String get checkInboxBody =>
      'We\'ve sent a password reset link to your email.';

  @override
  String get profileTitle => 'Account';

  @override
  String get language => 'Language';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get errorFullNameEmpty => 'Please enter your full name.';

  @override
  String get errorEmailEmpty => 'Please enter your email.';

  @override
  String get errorPasswordWeak => 'Minimum 8 characters, letters and numbers.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password';

  @override
  String get errorEmailNotConfirmed =>
      'Please check your email to verify your account';

  @override
  String get save => 'Save';

  @override
  String get nameEditTitle => 'Edit name';

  @override
  String get labelPhone => 'Phone number';

  @override
  String get profilePersonalInfo => 'Personal info';

  @override
  String get profilePersonalInfoSub => 'Name, avatar, phone number';

  @override
  String get profileNotificationsLabel => 'Notifications';

  @override
  String get profileNotificationsLabelSub => 'Push, email, play invites';

  @override
  String get profileFavourites => 'Favourite courts';

  @override
  String get profilePlayTogether => 'Play-together friends';

  @override
  String get profileReferral => 'Refer a friend, get a free game';

  @override
  String get profileReferralSub => '1 free game per referral';

  @override
  String get profileHelpCenter => 'Help centre';

  @override
  String get profileTerms => 'Terms & Privacy';

  @override
  String get profileActivitySection => 'ACTIVITY';

  @override
  String get profileSupportSection => 'SUPPORT';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String profileGamesCount(int count) {
    return '$count games';
  }

  @override
  String profileFavouritesCount(int count) {
    return '$count favourites';
  }

  @override
  String get errorAvatarFormat => 'Avatar must be in JPEG or PNG format.';

  @override
  String get errorAvatarSize => 'Avatar size must not exceed 2 MB.';

  @override
  String get navMap => 'Explore';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSlots => 'Open Slots';

  @override
  String get commonFilter => 'Filter';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonNotifications => 'Notifications';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonBack => 'Back';

  @override
  String get sportAll => 'All';

  @override
  String get sportFootball => 'Football';

  @override
  String get sportPickleball => 'Pickleball';

  @override
  String get sportBadminton => 'Badminton';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportMulti => 'Multi-sport';

  @override
  String get sportGeneric => 'Sports';

  @override
  String availabilityOpenSlots(int count) {
    return '$count open slots';
  }

  @override
  String get availabilityFull => 'Full';

  @override
  String distanceKm(String km) {
    return '$km km';
  }

  @override
  String get distanceWithin5 => 'Within 5 km';

  @override
  String get discoveryTitle => 'Explore';

  @override
  String get discoveryUpdating => 'Updating…';

  @override
  String get discoveryNoMatch => 'No courts match the filters';

  @override
  String discoverySubtitle(int count, int slots) {
    return '$count courts · $slots open slots nearby';
  }

  @override
  String discoveryCourtsCount(int count) {
    return '$count courts';
  }

  @override
  String get discoverySortNearest => 'Nearest ↓';

  @override
  String get discoveryFooterEnd =>
      'No more courts within the selected distance';

  @override
  String get discoveryAllFullTitle => 'All nearby courts are fully booked.';

  @override
  String get discoveryAllFullAction => 'View open slots →';

  @override
  String get discoveryEmptyNoOpen => 'No open slots here';

  @override
  String get discoveryEmptyNoCourts => 'No courts found';

  @override
  String get discoveryEmptyBody =>
      'Try widening the distance or removing filters to see more options.';

  @override
  String get discoveryEmptyExpand => 'Expand to 5 km';

  @override
  String get discoveryEmptyResetFilters => 'Reset filters';

  @override
  String get filterSports => 'Sport';

  @override
  String get filterDistance => 'Distance';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterOnlyOpen => 'Only show courts with open slots';

  @override
  String filterApply(int count) {
    return 'Show $count courts';
  }

  @override
  String get filterApplyZero => 'View results · 0 courts';

  @override
  String get searchHint => 'Search courts, areas…';

  @override
  String searchAllCourts(int total) {
    return 'All $total courts · nearest first';
  }

  @override
  String searchResultsFor(int count, String query) {
    return '$count results for \"$query\"';
  }

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchTryOther => 'Try another court name or area.';

  @override
  String get slotsTitle => 'Open Slots';

  @override
  String get slotsSubtitle => 'Slots looking for players';

  @override
  String slotsCountSort(int count) {
    return '$count slots · Sort: Soonest ↓';
  }

  @override
  String get slotsHostInvite => 'Host invites you to play';

  @override
  String get slotsOpenMatch => '🌐 Open match';

  @override
  String get slotsFull => 'Full';

  @override
  String slotsJoinedCount(int joined, int max) {
    return '$joined/$max people';
  }

  @override
  String get slotsEmptyTitle => 'No open slots';

  @override
  String get slotsEmptyBody => 'No slots looking for players in your area.';

  @override
  String get bookingValidationName => 'Please enter your name';

  @override
  String get bookingValidationPhone => 'Please enter your phone number';

  @override
  String get bookingValidationPhoneInvalid => 'Invalid phone number';

  @override
  String get bookingSlotTaken =>
      'This slot was just booked, please pick another time';

  @override
  String get bookingConfirmTitle => 'Confirm booking';

  @override
  String bookingDurationHours(String hours) {
    return '$hours h';
  }

  @override
  String get bookingSelectedSlot => 'Selected time slot';

  @override
  String bookingSlotCountDuration(String duration) {
    return '1 slot · $duration';
  }

  @override
  String get bookingTotalDuration => 'Total duration';

  @override
  String get bookingRentPrice => 'Rental price';

  @override
  String bookingPricePerHour(String price) {
    return '$price/hour';
  }

  @override
  String get bookingServiceFee => 'Service fee';

  @override
  String get bookingFree => 'Free';

  @override
  String get bookingTotalPayment => 'Total payment';

  @override
  String get bookingCashAtCourt => 'Pay cash at the court';

  @override
  String get bookingContactInfo => 'Contact information';

  @override
  String get bookingFieldName => 'Full name';

  @override
  String get bookingFieldPhone => 'Phone number';

  @override
  String get bookingFieldNotes => 'Note for the court owner (optional)';

  @override
  String get bookingNotesHint =>
      'e.g. need to borrow a racket, arriving 10 min late...';

  @override
  String get myBookingsTitle => 'My bookings';

  @override
  String get bookingsTabUpcoming => 'Upcoming';

  @override
  String get bookingsTabPending => 'Pending';

  @override
  String get bookingsTabHistory => 'History';

  @override
  String get bookingsFilterAll => 'All';

  @override
  String get bookingsFilterHost => 'Hosted';

  @override
  String get bookingsFilterJoin => 'Joined';

  @override
  String get bookingsFilterRecurring => '🔁 Recurring';

  @override
  String get bookingsFilterCompleted => 'Completed';

  @override
  String get bookingsEmptyUpcoming => 'No bookings yet';

  @override
  String get bookingsEmptyPending => 'No pending bookings';

  @override
  String get bookingsEmptyHistory => 'No booking history';

  @override
  String get bookingsToday => 'TODAY';

  @override
  String get bookingsTomorrow => 'TOMORROW';

  @override
  String get bookingsWeekdaySun => 'SUNDAY';

  @override
  String get bookingsWeekdayMon => 'MONDAY';

  @override
  String get bookingsWeekdayTue => 'TUESDAY';

  @override
  String get bookingsWeekdayWed => 'WEDNESDAY';

  @override
  String get bookingsWeekdayThu => 'THURSDAY';

  @override
  String get bookingsWeekdayFri => 'FRIDAY';

  @override
  String get bookingsWeekdaySat => 'SATURDAY';

  @override
  String get bookingsPendingHeader => 'BOOKINGS AWAITING CONFIRMATION';

  @override
  String get commonRetry => 'Retry';

  @override
  String get bookingsCancelTitle => 'Cancel this booking?';

  @override
  String get bookingsCancelBody => 'This action cannot be undone.';

  @override
  String get commonNo => 'No';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String bookingsJoinedHost(String host) {
    return 'You joined · host $host';
  }

  @override
  String bookingsHostWithPlayers(String players) {
    return 'You\'re the host · $players';
  }

  @override
  String get bookingsHost => 'You\'re the host';

  @override
  String get bookingsOneOff => 'One-off';

  @override
  String bookingsExtraSlots(int count) {
    return '+$count slots';
  }

  @override
  String get bookingsLegendHost => 'You booked';

  @override
  String get bookingsLegendJoin => 'You joined (joined a slot)';

  @override
  String get bookingActionRebook => 'Rebook';

  @override
  String get bookingActionDetail => 'Details';

  @override
  String get bookingActionCancel => 'Cancel';

  @override
  String get bookingStatusApproved => 'Approved';

  @override
  String get bookingStatusConfirmed => 'Confirmed';

  @override
  String get bookingStatusPendingJoin => 'Awaiting approval';

  @override
  String get bookingStatusPendingHost => 'Awaiting confirmation';

  @override
  String get bookingStatusCancelled => 'Cancelled';

  @override
  String get bookingJoinAccepted => 'Accepted';

  @override
  String get bookingJoinRejected => 'Rejected';
}
