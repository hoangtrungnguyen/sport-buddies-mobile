/// Canonical flag keys. Always reference flags through these constants —
/// raw strings in `isEnabled(...)` fail silently on a typo.
abstract final class FeatureNames {
  // Core
  static const bookingManagement = 'booking_management';
  static const basicAnalytics = 'basic_analytics';
  static const venueSettings = 'venue_settings';

  // Plan features (pro+)
  static const advancedAnalytics = 'advanced_analytics';
  static const staffManagement = 'staff_management';
  static const bulkBookingActions = 'bulk_booking_actions';

  // Beta / experimental
  static const aiDemandForecast = 'ai_demand_forecast';
  static const payoutDashboard = 'payout_dashboard';

  // Observability
  static const sentryCrashReporting = 'sentry_crash_reporting';
  static const performanceMonitoring = 'performance_monitoring';

  // Debug
  static const debugPanel = 'debug_panel';
  static const verboseLogging = 'verbose_logging';
}
