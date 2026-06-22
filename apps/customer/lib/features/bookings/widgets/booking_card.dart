// Booking card + its leaf widgets (role line, sport icon, badges, action
// button) for the My Bookings tabs. Extracted from my_bookings_screen.dart.

import 'package:customer/features/bookings/booking_view.dart';
import 'package:customer/features/bookings/bookings_cubit.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─── Booking card ─────────────────────────────────────────────────────────────

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final BookingView booking;

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.bookingsCancelTitle),
        content: Text(l10n.bookingsCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.commonConfirm,
              style: const TextStyle(color: mdError),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<BookingsCubit>().cancelBooking(booking.id);
    }
  }

  VoidCallback _actionTap(BuildContext context) {
    return switch (booking.action) {
      'rebook' when booking.courtId != null => () => context.push(
        '/browse/court/${booking.courtId}',
      ),
      'detail' => () => context.push('/bookings/${booking.id}'),
      'cancel' => () => _confirmCancel(context),
      _ => () {},
    };
  }

  VoidCallback? _cardTap(BuildContext context) {
    return switch (booking.status) {
      BookingStatus.pending => () => context.push(
        '/booking/awaiting/${booking.id}',
      ),
      BookingStatus.confirmed => () => context.push('/bookings/${booking.id}'),
      BookingStatus.completed || BookingStatus.cancelled => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isHost = booking.role == BookingRole.host;
    final railColor = isHost ? mdPrimary : mdSecondary;
    final iconBg = isHost ? mdPrimaryContainer : mdSecondaryContainer;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _cardTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: mdOutlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardHeader(booking: booking, iconBg: iconBg),
                    const SizedBox(height: 12),
                    Container(height: 1, color: mdOutlineVariant),
                    const SizedBox(height: 12),
                    _CardFooter(booking: booking, onAction: _actionTap(context)),
                  ],
                ),
              ),
              // Role rail
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(width: 4, color: railColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card header (sport icon + court/role/detail + status badge) ──────────────

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.booking, required this.iconBg});

  final BookingView booking;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SportIconBox(
                sport: booking.sport,
                slots: booking.slots,
                iconBg: iconBg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.courtName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: mdOnSurface,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _TypeBadge(type: booking.type),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _RoleLine(booking: booking),
                    const SizedBox(height: 2),
                    Text(
                      booking.detail,
                      style: const TextStyle(
                        fontSize: 12,
                        color: mdOnSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (booking.recurringLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        booking.recurringLabel!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _M3Badge(
          status: booking.status,
          role: booking.role,
          overrideToken: booking.statusOverrideToken,
        ),
      ],
    );
  }
}

// ─── Card footer (time · slots · price + action button) ───────────────────────

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.booking, required this.onAction});

  final BookingView booking;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.access_time,
              size: 15,
              color: mdOnSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              booking.time,
              style: const TextStyle(
                fontSize: 13,
                color: mdOnSurfaceVariant,
              ),
            ),
            if (booking.slots > 1) ...[
              const SizedBox(width: 8),
              _MultiSlotBadge(extraSlots: booking.slots - 1),
            ],
            const SizedBox(width: 8),
            Text(
              booking.price,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: mdOnSurface,
              ),
            ),
          ],
        ),
        if (booking.action != null)
          _ActionButton(
            label: actionLabel(
              AppLocalizations.of(context),
              booking.action!,
            ),
            danger: booking.actionDanger,
            onTap: onAction,
          ),
      ],
    );
  }
}

class _RoleLine extends StatelessWidget {
  const _RoleLine({required this.booking});

  final BookingView booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (booking.role == BookingRole.join) {
      return Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: booking.hostColor ?? mdOnSurfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                booking.hostInitials ?? '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l10n.bookingsJoinedHost(booking.hostName ?? ''),
              style: const TextStyle(
                fontSize: 12,
                color: mdSecondary,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const HostCrown(color: mdPrimary, size: 13),
        const SizedBox(width: 5),
        Text(
          booking.players != null
              ? l10n.bookingsHostWithPlayers(booking.players!)
              : l10n.bookingsHost,
          style: const TextStyle(
            fontSize: 12,
            color: mdPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SportIconBox extends StatelessWidget {
  const _SportIconBox({
    required this.sport,
    required this.slots,
    required this.iconBg,
  });

  final SportType sport;
  final int slots;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                bookingSportEmoji(sport),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          if (slots > 1)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: mdPrimary,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: mdSurfaceContainerLowest, width: 2),
                ),
                child: Text(
                  '$slots',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final BookingType type;

  @override
  Widget build(BuildContext context) {
    final isRecurring = type == BookingType.recurring;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isRecurring ? mdPrimaryContainer : mdSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(
          isRecurring
              ? AppLocalizations.of(context).bookingsFilterRecurring
              : AppLocalizations.of(context).bookingsOneOff,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isRecurring ? FontWeight.w700 : FontWeight.w600,
            color: isRecurring ? mdOnPrimaryContainer : mdOnSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _M3Badge extends StatelessWidget {
  const _M3Badge({
    required this.status,
    required this.role,
    this.overrideToken,
  });

  final BookingStatus status;
  final BookingRole role;
  final String? overrideToken;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = overrideToken != null
        ? overrideLabel(l10n, overrideToken!)
        : statusLabel(l10n, status, role);
    final (bg, fg, dot) = switch (status) {
      BookingStatus.confirmed => (
        mdPrimaryContainer,
        mdOnPrimaryContainer,
        mdPrimary,
      ),
      BookingStatus.pending => (
        mdTertiaryContainer,
        mdOnTertiaryContainer,
        mdTertiary,
      ),
      BookingStatus.completed || BookingStatus.cancelled => (
        mdSurfaceContainerHighest,
        mdOnSurfaceVariant,
        mdOnSurfaceVariant,
      ),
    };
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: mdCornerFull),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiSlotBadge extends StatelessWidget {
  const _MultiSlotBadge({required this.extraSlots});

  final int extraSlots;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: mdPrimaryContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context).bookingsExtraSlots(extraSlots),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: mdOnPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.danger,
    required this.onTap,
  });

  final String label;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: danger ? Colors.transparent : mdSecondaryContainer,
          borderRadius: BorderRadius.circular(99),
          border: danger ? Border.all(color: mdError) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: danger ? mdError : mdOnSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}
