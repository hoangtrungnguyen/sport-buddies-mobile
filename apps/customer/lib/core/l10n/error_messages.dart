// Maps stable cubit error codes to localized, user-facing text. Cubits have no
// BuildContext, so they emit a code (e.g. 'network') into their error state and
// the display layer resolves it here. Unknown codes pass through unchanged so
// server-provided or already-localized text still renders.

import 'package:customer/l10n/app_localizations.dart';

String appErrorMessage(AppLocalizations l10n, String code) => switch (code) {
  'network' => l10n.errNetwork,
  'server' => l10n.errServer,
  'auth' => l10n.errAuth,
  'relogin' => l10n.errReLogin,
  'slot_load' => l10n.errSlotLoad,
  'center_not_found' => l10n.errCenterNotFound,
  'schedule_empty' => l10n.errScheduleEmpty,
  'schedule_load' => l10n.errScheduleLoad,
  'send_request' => l10n.errSendRequest,
  'send_notify' => l10n.errSendNotify,
  'players_load' => l10n.errPlayersLoad,
  'generic' => l10n.errGeneric,
  'last_call_sent' => l10n.infoLastCallSent,
  _ => code,
};
