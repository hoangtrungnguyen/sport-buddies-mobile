import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// Domain models for the new "Lịch sân" (venue schedule) screen.
///
/// Terminology (per the design handoff — the HTML prototype mislabels these):
/// - **Court** = the business/physical facility owned by the user. The whole
///   screen is scoped to one court (selected elsewhere / from session).
/// - **Venue** = an individual playing surface inside a court (the prototype's
///   `SC_COURTS` / `courtId`). Day-view resource columns are venues.

/// Matchmaking ("Slot mở (ghép)") and private-hold slots have no database
/// representation yet — `slots.status` only knows
/// `open | booked | pending | owner | blocked | maintenance` — so the UI for
/// them is gated off rather than fed fabricated data.
///
/// TODO(BCORE-321/326): flip to true once the backend supports matchmaking /
/// private slots; the create-sheet type cards, the detail-sheet "Mở ghép"
/// action, the legend rows and the TRẠNG THÁI chips un-gate automatically.
const bool kMatchmakingEnabled = false;

/// The [SlotState]s gated behind [kMatchmakingEnabled] — they can never occur
/// from real data today, so legend / filter chips hide them.
const Set<SlotState> kMatchmakingOnlyStates = {
  SlotState.fixed,
  SlotState.open,
  SlotState.private,
};

/// Sentinel-venue prefix for the "Chung (cả sân)" lane — venue-less slots
/// (`slots.venue_id IS NULL`) of one court. The repository encodes/decodes
/// this client-side id; the API never sees it (`venue_id` is simply omitted).
const String kGeneralVenuePrefix = 'general:';

/// The synthetic "Chung (cả sân)" venue id of [courtId].
String generalVenueId(String courtId) => '$kGeneralVenuePrefix$courtId';

/// Whether [venueId] is a synthetic "Chung (cả sân)" id (vs a real venue
/// uuid).
bool isGeneralVenueId(String venueId) =>
    venueId.startsWith(kGeneralVenuePrefix);

/// The court id encoded in a `general:<courtId>` sentinel.
String courtIdOfGeneralVenue(String venueId) =>
    venueId.substring(kGeneralVenuePrefix.length);

/// Slot lifecycle / display state. Drives colours, icons, labels and the
/// detail-sheet actions (see `style/slot_state_style.dart`).
enum SlotState {
  /// Booked & confirmed.
  confirmed,

  /// Awaiting owner approval.
  pending,

  /// Recurring fixed appointment.
  fixed,

  /// Public matchmaking slot ("public" in the HTML) — players join until full.
  open,

  /// Reserved/held, not publicly listed.
  private,

  /// Created bookable slot, no customer yet.
  empty,

  /// Owner personal / internal use.
  owner,

  /// Repair / cleaning.
  maintenance,

  /// Closed / not accepting bookings.
  locked,
}

/// Payment status of a booking (`paid` in the prototype data).
enum PaymentStatus { paid, partial, unpaid }

/// The three calendar views of the screen.
enum ScheduleView { day, week, month }

/// Sport played on a venue — drives the "MÔN" filter chips.
enum SportType { football, pickleball, tennis }

/// Vietnamese filter-chip label for each sport (`SC_SPORTS` in the prototype).
extension SportTypeLabel on SportType {
  String get label => switch (this) {
        SportType.football => 'Bóng đá',
        SportType.pickleball => 'Pickleball',
        SportType.tennis => 'Tennis',
      };
}

/// One owner court — the schedule's court picker options. The whole screen
/// is scoped to one selected court; its venues are the Day-view columns.
@freezed
abstract class ScheduleCourt with _$ScheduleCourt {
  const factory ScheduleCourt({
    required String id,
    required String name,
  }) = _ScheduleCourt;
}

/// An individual playing surface inside the court (prototype `SC_COURTS`).
@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required String id,

    /// "Sân 1"
    required String name,

    /// "S1"
    required String shortCode,
    required SportType sport,

    /// Display string, e.g. "Bóng đá 5v5".
    required String sportLabel,

    /// Venue dot colour as an ARGB int (see handoff venue palette).
    required int colorValue,

    /// VND.
    required int pricePerHour,

    /// Daily operating window start (24h), from `courts.operating_hours`.
    /// Null when the court has no parseable operating hours — consumers
    /// apply their own fallback instead of treating a guess as real data.
    int? openHour,

    /// Daily operating window end (24h) — see [openHour].
    int? closeHour,
  }) = _Venue;
}

/// A scheduled block of time on a venue — booking, open slot, block, etc.
@freezed
abstract class Slot with _$Slot {
  const Slot._();

  const factory Slot({
    required String id,
    required String venueId,
    required SlotState state,

    /// 24h decimal hour, `.5` = `:30` — e.g. 18.0, 19.5.
    required double startHour,

    /// e.g. 1.5.
    required double durationHours,

    /// Day this slot belongs to (Day/Week views).
    DateTime? date,

    /// 0 = Mon … 6 = Sun (Week view positioning).
    int? weekday,

    /// Customer/team name OR "Slot trống"/"Bảo trì".
    required String label,

    /// "Cố định T3·T5", "Đang ghép đội", etc.
    String? subtitle,

    /// Joined count (open/booked group slots).
    int? players,

    /// Max players.
    int? capacity,

    /// VND for this slot.
    int? price,
    PaymentStatus? payment,

    /// "SPB-060149".
    String? bookingCode,
  }) = _Slot;

  /// End time in decimal hours.
  double get endHour => startHour + durationHours;

  /// Capacity badge / "Người chơi" text: the real joined count when known
  /// ("3/10"), otherwise only the DB-backed maximum ("tối đa 10"). The DB has
  /// no joined-count column today, so [players] is always null from real data
  /// — rendering "0/10" would fabricate a zero. Null when [capacity] is null.
  String? get capacityLabel {
    final cap = capacity;
    if (cap == null) return null;
    final joined = players;
    return joined != null ? '$joined/$cap' : 'tối đa $cap';
  }
}

/// One cell of the Month-view occupancy heatmap (prototype `MONTH_CELLS`).
@freezed
abstract class OccupancyDay with _$OccupancyDay {
  const factory OccupancyDay({
    required DateTime date,

    /// 0.0–1.0.
    required double occupancy,
    required int bookings,

    /// VND.
    required int revenue,
    @Default(false) bool isToday,
    @Default(false) bool isCurrentMonth,
  }) = _OccupancyDay;
}

/// Payload for `ScheduleRepository.createSlot` / `createRecurringSlots` —
/// also used as the Create-sheet prefill (empty-cell tap / "Tạo slot mới").
@freezed
abstract class CreateSlotRequest with _$CreateSlotRequest {
  const CreateSlotRequest._();

  const factory CreateSlotRequest({
    required String venueId,

    /// 24h decimal, snapped to 30-minute increments.
    required double startHour,

    /// 1 / 1.5 / 2 / 2.5 / 3.
    @Default(1.0) double durationHours,

    /// Day the slot lands on (Day view / single create).
    DateTime? date,

    /// 0 = Mon … 6 = Sun (Week view create).
    int? weekday,

    /// One of [SlotState.empty] (Slot trống), [SlotState.open]
    /// (Slot mở (ghép)) or [SlotState.private] (Slot riêng).
    @Default(SlotState.empty) SlotState slotType,

    /// Open-slot extras ("Số người tối đa") — only when [slotType] is open.
    int? capacity,

    /// Open-slot extras ("Giá / người"), VND — only when [slotType] is open.
    int? pricePerPerson,
    String? note,
  }) = _CreateSlotRequest;

  /// End time in decimal hours — drives the "Kết thúc lúc HH:MM" hint.
  double get endHour => startHour + durationHours;
}

/// Payload for `ScheduleRepository.blockTime` — also used as the Block-sheet
/// prefill (drag-to-block / "Khoá giờ").
@freezed
abstract class BlockTimeRequest with _$BlockTimeRequest {
  const BlockTimeRequest._();

  const factory BlockTimeRequest({
    required String venueId,

    /// 24h decimal, snapped to 30-minute increments.
    required double startHour,
    @Default(1.0) double durationHours,

    /// Day being blocked (Day view drag).
    DateTime? date,

    /// 0 = Mon … 6 = Sun (Week view drag).
    int? weekday,

    /// One of [SlotState.locked] (Khoá giờ), [SlotState.maintenance]
    /// (Bảo trì) or [SlotState.owner] (Sân của tôi).
    @Default(SlotState.locked) SlotState blockType,
    String? note,
  }) = _BlockTimeRequest;

  /// End time in decimal hours.
  double get endHour => startHour + durationHours;
}
