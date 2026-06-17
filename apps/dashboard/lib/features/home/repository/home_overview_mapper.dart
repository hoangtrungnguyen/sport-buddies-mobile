import '../model/home_models.dart';
import '../util/home_format.dart';

/// Parses the `/api/home/overview` payload into a [HomeOverview], building all
/// display strings client-side (the backend sends raw ints / ISO timestamps).
/// Pure — [now] is injected so the "Hôm nay" / today-bucket logic is testable.
HomeOverview mapHomeOverview(Map<String, dynamic> json, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final summary = _mapSummary(_obj(json['summary']));
  return HomeOverview(
    summary: summary,
    kpis: _mapKpis(_obj(json['kpis']), summary),
    requests: _mapRequests(_obj(json['pending_requests'])['items'], today),
    requestsTotal: _int(_obj(json['pending_requests'])['total']) ??
        _mapRequestsCount(json),
    upcoming: _mapUpcoming(_obj(json['upcoming'])['items']),
    weeklyRevenue: _mapRevenue(_obj(json['weekly_revenue'])['days'], today),
    courtStatus: _mapCourtStatus(_obj(json['court_status'])['items']),
  );
}

HomeSummary _mapSummary(Map<String, dynamic> s) => HomeSummary(
      ownerName: _str(s['owner_name']),
      activeCourts: _int(s['active_courts']) ?? 0,
      totalVenues: _int(s['total_venues']) ?? 0,
    );

/// Fallback when `pending_requests.total` is absent — the KPI count.
int _mapRequestsCount(Map<String, dynamic> json) =>
    _int(_obj(_obj(json['kpis'])['pending_requests'])['count']) ?? 0;

List<HomeKpi> _mapKpis(Map<String, dynamic> k, HomeSummary summary) {
  final revenue = _obj(k['revenue']);
  final bookings = _obj(k['bookings']);
  final occupancy = _obj(k['occupancy']);
  final pending = _obj(k['pending_requests']);

  final revToday = _int(revenue['today']) ?? 0;
  final revDelta = _int(revenue['delta_pct']) ?? 0;
  final bookingCount = _int(bookings['count']) ?? 0;
  final bookingPending = _int(bookings['pending']) ?? 0;
  final occPct = _int(occupancy['pct']) ?? 0;
  final pendCount = _int(pending['count']) ?? 0;
  final pendOverdue = _int(pending['overdue']) ?? 0;

  return [
    HomeKpi(
      id: 'revenue',
      label: 'Doanh thu hôm nay',
      value: vndCurrency(revToday),
      delta: signedPercent(revDelta),
      deltaUp: _bool(revenue['delta_up']) ?? (revDelta >= 0),
      sub: 'so với hôm qua',
      tone: KpiTone.primary,
      icon: 'payments',
    ),
    HomeKpi(
      id: 'bookings',
      label: 'Lượt đặt hôm nay',
      value: '$bookingCount',
      unit: 'lượt',
      delta: bookingPending > 0 ? '$bookingPending đang chờ' : null,
      sub: summary.totalVenues > 0 ? 'trên ${summary.totalVenues} sân con' : null,
      tone: KpiTone.tertiary,
      icon: 'event_available',
    ),
    HomeKpi(
      id: 'occupancy',
      label: 'Tỷ lệ lấp đầy',
      value: '$occPct%',
      progress: occPct,
      tone: KpiTone.secondary,
      icon: 'donut_large',
    ),
    HomeKpi(
      id: 'pending',
      label: 'Yêu cầu chờ duyệt',
      value: '$pendCount',
      unit: 'yêu cầu',
      delta: pendOverdue > 0 ? '$pendOverdue quá hạn' : null,
      deltaUp: pendOverdue > 0 ? false : null,
      // tone=warn only when something is overdue (HOME_API_HANDOFF §4).
      tone: pendOverdue > 0 ? KpiTone.warn : KpiTone.tertiary,
      icon: 'inbox',
    ),
  ];
}

List<PendingRequest> _mapRequests(dynamic raw, DateTime today) {
  if (raw is! List) return const [];
  final out = <PendingRequest>[];
  for (final r in raw) {
    if (r is! Map) continue;
    final m = r.cast<String, dynamic>();
    final start = _date(m['start_at']);
    final end = _date(m['end_at']);
    final name = _str(m['customer_name']) ?? 'Khách';
    out.add(PendingRequest(
      id: _str(m['id']) ?? '',
      kind: m['kind'] == 'join_request'
          ? PendingKind.joinRequest
          : PendingKind.booking,
      name: name,
      initials: initialsFrom(name),
      court: _str(m['court_name']) ?? '',
      venue: _str(m['venue_name']) ?? '',
      sport: _str(m['sport']) ?? '',
      when: (start != null && end != null)
          ? whenLabel(start, end, today)
          : '',
      price: _int(m['price']) ?? 0,
      regular: _bool(m['regular']) ?? false,
    ));
  }
  return out;
}

List<UpcomingSession> _mapUpcoming(dynamic raw) {
  if (raw is! List) return const [];
  final out = <UpcomingSession>[];
  for (final r in raw) {
    if (r is! Map) continue;
    final m = r.cast<String, dynamic>();
    final start = _date(m['start_at']);
    final end = _date(m['end_at']);
    final where = [
      if ((_str(m['court_name']) ?? '').isNotEmpty) _str(m['court_name']),
      if ((_str(m['venue_name']) ?? '').isNotEmpty) _str(m['venue_name']),
    ].whereType<String>().join(' · ');
    out.add(UpcomingSession(
      id: _str(m['id']) ?? '',
      time: start != null ? hhmm(start) : '',
      end: end != null ? hhmm(end) : '',
      name: _str(m['name']) ?? 'Khách vãng lai',
      where: where,
      status: m['status'] == 'walkin'
          ? SessionStatus.walkin
          : SessionStatus.confirmed,
    ));
  }
  return out;
}

List<RevenueDay> _mapRevenue(dynamic raw, DateTime today) {
  if (raw is! List) return const [];
  final out = <RevenueDay>[];
  for (final r in raw) {
    if (r is! Map) continue;
    final m = r.cast<String, dynamic>();
    final date = _date(m['date']);
    final isToday = date != null &&
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    out.add(RevenueDay(
      day: date == null
          ? '—'
          : (isToday ? 'Hôm nay' : weekdayShort(date)),
      value: _int(m['value']) ?? 0,
      today: isToday,
    ));
  }
  return out;
}

List<CourtStatusRow> _mapCourtStatus(dynamic raw) {
  if (raw is! List) return const [];
  final out = <CourtStatusRow>[];
  for (final r in raw) {
    if (r is! Map) continue;
    final m = r.cast<String, dynamic>();
    out.add(CourtStatusRow(
      id: _str(m['id']) ?? '',
      name: _str(m['name']) ?? '',
      venues: _int(m['venues_count']) ?? 0,
      occupancy: _int(m['occupancy_pct']) ?? 0,
      status: m['status'] == 'active' ? CourtState.active : CourtState.draft,
    ));
  }
  return out;
}

// --- parse helpers -----------------------------------------------------------

Map<String, dynamic> _obj(dynamic v) =>
    v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _int(dynamic v) => v is int ? v : (v is num ? v.toInt() : null);

bool? _bool(dynamic v) => v is bool ? v : null;

/// Parses an ISO 8601 timestamp (with offset) to local time, or a bare
/// `YYYY-MM-DD` to local midnight.
DateTime? _date(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  final parsed = DateTime.tryParse(v);
  return parsed?.toLocal();
}
