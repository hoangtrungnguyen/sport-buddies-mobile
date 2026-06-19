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

  @override
  String get commonClose => 'Close';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get wizardStepConfirm => 'Confirm';

  @override
  String get wizardStepPlay => 'Play';

  @override
  String get wizardStepAwait => 'Awaiting';

  @override
  String get wizardStepDone => 'Done';

  @override
  String get wizardStepPlayTitle => 'Who\'s playing?';

  @override
  String get wizardStepAwaitingTitle => 'Awaiting confirmation';

  @override
  String get wizardSkip => 'Skip';

  @override
  String get wizardSaveContinue => 'Save & continue';

  @override
  String get wizardViewBookings => 'View bookings';

  @override
  String get wizardBackToMap => 'Back to map';

  @override
  String get wizardRaceLost => 'This slot was just booked';

  @override
  String get wizardNetworkFailed => 'Couldn\'t book, try again';

  @override
  String get wizardTotalRent => 'Total rental';

  @override
  String get wizardContactHint => 'This info is sent to the court owner.';

  @override
  String get wizardAdjacent => 'adjacent';

  @override
  String get wizardAnd => 'and';

  @override
  String wizardMergeNotice(String names, String duration) {
    return 'Adjacent slots $names will be merged into one $duration session.';
  }

  @override
  String wizardSelectedSlots(int count) {
    return 'Selected $count slots';
  }

  @override
  String get wizardPickPlayers =>
      'Choose who plays with you before sending the request to the owner.';

  @override
  String get wizardWhoCanJoin => 'Who can join?';

  @override
  String wizardAccessApplies(int count) {
    return 'Applies to all $count booked slots. You can change each slot individually after booking.';
  }

  @override
  String get wizardPrivate => '🔒 Private';

  @override
  String get wizardPrivateDesc => 'Only you and people you invite can play.';

  @override
  String get wizardOpen => '🌐 Open match';

  @override
  String get wizardOpenDesc =>
      'Your slot appears in \"Open slots\". You approve join requests.';

  @override
  String get wizardMaxPlayers => 'Max players';

  @override
  String get wizardDecrease => 'Decrease players';

  @override
  String get wizardIncrease => 'Increase players';

  @override
  String get wizardMaxPlayersHint =>
      'Includes you. 4 recommended for pickleball doubles.';

  @override
  String get wizardDeclinedTitle => 'Owner can\'t accept';

  @override
  String get wizardWaitingTitle => 'Waiting for owner confirmation';

  @override
  String get wizardDeclinedBody =>
      'Sorry, the owner can\'t accept this request. You can pick another time.';

  @override
  String wizardWaitingBody(int count, String court) {
    return 'Your request for $count slots was sent to $court. The owner usually responds within a few minutes. You\'ll be notified as soon as there\'s a result.';
  }

  @override
  String get wizardNotConfirmed => 'Request not yet confirmed.';

  @override
  String get wizardPickAnotherTime => 'Pick another time';

  @override
  String get wizardBookingId => 'Booking ID';

  @override
  String wizardCourtSlots(String court, int count) {
    return '$court · $count slots';
  }

  @override
  String get wizardTimelineSent => 'You sent the booking request';

  @override
  String get wizardTimelineDeclined => 'Owner declined';

  @override
  String get wizardTimelineWaiting => 'Waiting for owner response...';

  @override
  String get wizardWaitingShort => 'waiting';

  @override
  String get wizardTimelineConfirmed => 'Booking confirmed';

  @override
  String get wizardAwaitingSemantic => 'Waiting for the owner to confirm';

  @override
  String get wizardSuccessTitle => 'Booking successful!';

  @override
  String wizardSuccessBody(String court) {
    return 'See you at $court.\nArrive on time and bring cash.';
  }

  @override
  String get wizardBringCash => 'Remember to bring cash';

  @override
  String wizardBringCashBody(String total, int count) {
    return 'Pay $total at the court when you arrive (for all $count slots).';
  }

  @override
  String get wizardLabelCourt => 'Court';

  @override
  String get wizardLabelDate => 'Date';

  @override
  String get wizardLabelSlots => 'Slots';

  @override
  String get wizardLabelTotal => 'Total';

  @override
  String wizardMergedSuffix(int count) {
    return ' (merged $count slots)';
  }

  @override
  String wizardHours(String value) {
    return '$value h';
  }

  @override
  String wizardSlotCountDuration(int count, String duration) {
    return '$count slots · $duration';
  }

  @override
  String get courtDetailBookCta => 'Pick a free slot & book';

  @override
  String get courtDetailOpenSlotsHelper => 'Join other players at this court';

  @override
  String courtDetailPhoto(int index, int total) {
    return 'court photo · $index/$total';
  }

  @override
  String get courtDetailFavorite => 'Favorite';

  @override
  String get courtDetailShare => 'Share';

  @override
  String courtDetailReviews(int count) {
    return '$count reviews';
  }

  @override
  String get courtDetailPricePerHour => 'Price / hour';

  @override
  String get courtDetailOpenToday => 'Open slots today';

  @override
  String courtDetailSlotCount(int count) {
    return '$count slots';
  }

  @override
  String get courtDetailAmenities => 'Amenities';

  @override
  String get courtDetailAbout => 'About';

  @override
  String get courtDetailScheduleTitle => 'Full schedule';

  @override
  String get courtDetailViewAllCourts => 'View all courts\' schedule';

  @override
  String get courtDetailScheduleSubtitle => 'Pick a time slot & book';

  @override
  String get slotPickerTitle => 'Pick a time';

  @override
  String get slotPickerDirectionsSoon => 'Directions — coming soon';

  @override
  String get slotPickerMultiHint => 'Tap to select multiple slots';

  @override
  String slotPickerOpenCount(int count) {
    return '$count open slots · book consecutively';
  }

  @override
  String get slotPickerOpenHelper => 'Tap for details & to request to join';

  @override
  String slotPickerDistanceDrive(String km) {
    return '$km km · ~6 min drive';
  }

  @override
  String get slotPickerDirections => 'Directions';

  @override
  String get slotPickerBooked => 'Booked';

  @override
  String get slotPickerClosed => 'Closed';

  @override
  String get slotPickerNoSelection => 'No slots selected';

  @override
  String slotPickerSelectedCount(int count, String duration) {
    return '$count slots selected · $duration';
  }

  @override
  String slotPickerContinue(int count) {
    return 'Continue · $count slots';
  }

  @override
  String get slotPickerPickSlots => 'Pick time slots';

  @override
  String get scheduleTitle => 'Court schedule';

  @override
  String get scheduleAllCourts => 'All courts\' schedule';

  @override
  String get scheduleToday => 'Today';

  @override
  String get scheduleDateWord => 'Date';

  @override
  String get scheduleBookedShort => 'Booked';

  @override
  String get scheduleLegendOpen => 'Available';

  @override
  String get scheduleLegendSelected => 'Selected';

  @override
  String scheduleSelectedCount(int count) {
    return 'Selecting · $count slots';
  }

  @override
  String get scheduleClearAll => 'Clear all';

  @override
  String get scheduleContinue => 'Continue to booking';

  @override
  String get paymentTime => 'Time';

  @override
  String paymentCashBody(String total) {
    return 'Pay $total at the court when you arrive.';
  }

  @override
  String get awaitingBody =>
      'Your booking request has been sent to the owner.\nYou\'ll be notified when there\'s a result.';

  @override
  String get accessSlotSelected => 'Time slot selected';

  @override
  String get accessApplies =>
      'Applies to the booked slot. You can change it after booking.';

  @override
  String get accessSlotTakenTitle => 'This slot is taken';

  @override
  String get accessSlotTakenBody =>
      'Sorry, someone just booked this slot before you.\nPlease pick another time.';

  @override
  String get bookingDetailTitle => 'Booking details';

  @override
  String get bookingDetailMode => 'Mode';

  @override
  String get bookingDetailCallOwner => 'Call owner';

  @override
  String get bookingDetailPlayers => 'Players';

  @override
  String get bookingDetailInvite => '+ Invite';

  @override
  String get bookingDetailYouHost => 'You (host)';

  @override
  String get bookingDetailHostRole => 'Host';

  @override
  String bookingDetailAcceptedAt(String time) {
    return 'Accepted · $time';
  }

  @override
  String get bookingDetailJoinRequests => 'Join requests';

  @override
  String bookingDetailNewCount(int count) {
    return '$count new';
  }

  @override
  String get bookingDetailNoRequests => 'No join requests yet';

  @override
  String get bookingDetailAccept => 'Accept';

  @override
  String get bookingDetailManagePlayers => 'Manage players';

  @override
  String get courtDetailOpenAddressIn => 'Open address in';

  @override
  String get courtDetailAppleMaps => 'Apple Maps';

  @override
  String get courtDetailGoogleMaps => 'Google Maps';

  @override
  String get courtDetailMapsUnavailable => 'Couldn\'t open a maps app';

  @override
  String get courtsOpenMatchSlots => 'Open match slots';

  @override
  String get courtsPriceFrom => 'From';

  @override
  String get courtsPerHourSuffix => '/hr';

  @override
  String get courtsBookNow => 'Book now';

  @override
  String get courtsSoldOutToday => 'Sold out today';

  @override
  String get courtsViewUpcoming => 'See open slots on upcoming days';

  @override
  String courtsSlotsLeft(int count) {
    return '· $count left';
  }

  @override
  String get courtsJoin => 'Join';

  @override
  String get courtsTomorrow => 'Tomorrow';

  @override
  String get scheduleTapHint => 'Tap an empty cell to pick a time slot';

  @override
  String get scheduleMultiHint =>
      'You can pick several consecutive slots to book longer.';

  @override
  String get schedulePickAtLeastOne => 'Pick at least 1 time slot to continue';

  @override
  String get commonContinue => 'Continue';

  @override
  String get slotPickerTapSelect => 'Tap to select';

  @override
  String get slotPickerNoSlotsToday => 'No open slots on this day.';

  @override
  String get slotPickerLocked => 'Locked';

  @override
  String get slotPickerMaintenance => 'Maintenance';

  @override
  String get slotPickerBookNow => 'Book now';

  @override
  String get courtsDefaultName => 'Sports court';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifMarkAllRead => 'Mark all read';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterBooking => 'Bookings';

  @override
  String get notifFilterPlayTogether => 'Play together';

  @override
  String get notifFilterReminder => 'Reminders';

  @override
  String get notifSectionToday => 'TODAY';

  @override
  String get notifSectionYesterday => 'YESTERDAY';

  @override
  String get notifSectionOlder => 'EARLIER';

  @override
  String get notifEmpty => 'No notifications';

  @override
  String notifEmptyInCategory(String filter) {
    return 'in $filter';
  }

  @override
  String get notifJoinApproved => 'Approved';

  @override
  String get notifJoinRejected => 'Declined';

  @override
  String get notifActionReject => 'Decline';

  @override
  String get notifActionApprove => 'Approve';

  @override
  String get notifTimeJustNow => 'Just now';

  @override
  String notifTimeMinutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String notifTimeHoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String notifTimeYesterdayAt(String time) {
    return 'Yesterday, $time';
  }

  @override
  String notifTimeDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get slotsManageTitle => 'Manage players';

  @override
  String get slotDetailTitle => 'Slot details';

  @override
  String get slotsPlayers => 'Players';

  @override
  String get slotsHostRole => 'Host';

  @override
  String slotsPlayersFraction(int filled, int max) {
    return '$filled/$max players';
  }

  @override
  String get slotsJoinRequestsTitle => 'Join requests';

  @override
  String get slotsAllRequestsHandled => 'All requests handled';

  @override
  String slotsSlotFullRemoveOne(int max) {
    return 'Slot is full ($max). Remove someone to accept more.';
  }

  @override
  String get slotsReject => 'Decline';

  @override
  String get slotsAccept => 'Accept';

  @override
  String slotsGamesPlayed(int count) {
    return '$count matches';
  }

  @override
  String get slotsSeeListBelow => 'See list below';

  @override
  String get slotsViewMap => 'View map';

  @override
  String get slotsHostMessageTitle => 'MESSAGE FROM HOST';

  @override
  String get slotsTimeSection => 'TIME';

  @override
  String slotsHoursLabel(String hours) {
    return '$hours h';
  }

  @override
  String get slotsFullTryOther =>
      'This slot is full. Try another slot at the same time near you.';

  @override
  String slotsSpotsLeftLevel(int count) {
    return '$count spots left · Intermediate level';
  }

  @override
  String get slotsEmptySpot => 'Open spot';

  @override
  String slotsPlayerN(int n) {
    return 'Player $n';
  }

  @override
  String get slotsRegisterToJoin => 'Join this match';

  @override
  String get slotsRequestSentPending => 'Request sent · Pending';

  @override
  String get slotsJoined => 'Joined';

  @override
  String get slotsRequestRejected => 'Request declined';

  @override
  String get sportBasketball => 'Basketball';

  @override
  String get browseOpenMatchSlots => 'Open match slots';

  @override
  String browseSlotsLeft(int count) {
    return '$count left';
  }

  @override
  String get browseJoin => 'Join';
}
