// A selected schedule cell — one court row × one hour column. Shared by the
// schedule page, its grid and the summary card. Extracted from schedule_page.dart.

class GridRef {
  const GridRef(this.courtId, this.hour);
  final String courtId;
  final int hour;

  @override
  bool operator ==(Object other) =>
      other is GridRef && other.courtId == courtId && other.hour == hour;

  @override
  int get hashCode => Object.hash(courtId, hour);
}
