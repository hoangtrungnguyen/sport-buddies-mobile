// Step 3 · Awaiting owner — "Đang chờ xác nhận" (SPB-044, handoff doc 02 Step 3).
//
// The advance to Step 4 is NOT a button — it is the realtime status→confirmed
// event driven by the cubit. This screen only listens and shows progress.

import 'dart:math' as math;

import 'package:customer/features/booking/wizard/cubit/booking_wizard_cubit.dart';
import 'package:customer/features/booking/wizard/domain/play_session.dart';
import 'package:customer/features/booking/wizard/presentation/widgets/common.dart';
import 'package:customer/features/booking/wizard/presentation/wizard_format.dart';
import 'package:customer/features/court/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Step3Awaiting extends StatelessWidget {
  const Step3Awaiting({super.key, required this.state});

  final BookingWizardState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final booking = state.booking;
    if (booking == null) return const SizedBox.shrink();

    final sessions = mergeSessions(state.draft.slots);
    final declined = state.declined;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Center(
          child: declined
              ? Icon(Icons.cancel, size: 96, color: scheme.error)
              : const AwaitingRing(),
        ),
        const SizedBox(height: 20),
        Semantics(
          liveRegion: true,
          child: Text(
            declined ? 'Chủ sân không thể nhận' : 'Chờ chủ sân xác nhận',
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            declined
                ? 'Rất tiếc, chủ sân không thể nhận yêu cầu này. Bạn có thể chọn '
                    'khung giờ khác.'
                : 'Yêu cầu đặt ${state.slotCount} khung giờ đã được gửi tới '
                    '${state.draft.courtLabel}. Chủ sân thường phản hồi trong vòng '
                    'vài phút. Bạn sẽ nhận thông báo ngay khi có kết quả.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        if (declined) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: AppTokens.radiusMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Yêu cầu chưa được xác nhận.',
                    style: text.bodySmall
                        ?.copyWith(color: scheme.onErrorContainer),
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Chọn giờ khác'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _BookingIdCard(
          idLabel: bookingIdLabel(booking.id),
          courtLabel: state.draft.courtLabel,
          slotCount: state.slotCount,
          dateDurTotal:
              '${dateLabel(state.draft.date)} · ${durationLabel(state.totalDuration)} · ${vnd(state.totalVnd)}',
          sessions: sessions,
        ),
        const SizedBox(height: 24),
        _StatusTimeline(
          sentAt: hm(booking.createdAt),
          declined: declined,
        ),
      ],
    );
  }
}

class _BookingIdCard extends StatelessWidget {
  const _BookingIdCard({
    required this.idLabel,
    required this.courtLabel,
    required this.slotCount,
    required this.dateDurTotal,
    required this.sessions,
  });

  final String idLabel;
  final String courtLabel;
  final int slotCount;
  final String dateDurTotal;
  final List<PlaySession> sessions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: AppTokens.radiusMd,
        boxShadow: AppTokens.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mã đặt sân',
                  style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant)),
              Text(idLabel,
                  style: text.labelLarge?.copyWith(fontFeatures: AppTokens.tnum)),
            ],
          ),
          Divider(height: 24, color: scheme.outlineVariant),
          Text('$courtLabel · $slotCount khung giờ', style: text.titleSmall),
          const SizedBox(height: 2),
          Text(dateDurTotal,
              style: text.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontFeatures: AppTokens.tnum,
              )),
          const SizedBox(height: 8),
          ...sessions.map((s) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '• ${timeRange(s.start, s.end)} · ${s.courtLabel}',
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
              )),
          const SizedBox(height: 12),
          const StatusBadge(kind: BadgeKind.pending, label: 'Chờ xác nhận'),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.sentAt, required this.declined});

  final String sentAt;
  final bool declined;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineItem(
          kind: _NodeKind.done,
          title: 'Bạn gửi yêu cầu đặt sân',
          time: sentAt,
        ),
        _TimelineItem(
          kind: declined ? _NodeKind.declined : _NodeKind.active,
          title: declined ? 'Chủ sân đã từ chối' : 'Chờ chủ sân phản hồi...',
          time: declined ? '' : 'đang chờ',
        ),
        const _TimelineItem(
          kind: _NodeKind.upcoming,
          title: 'Đặt sân được xác nhận',
          time: '',
          isLast: true,
        ),
      ],
    );
  }
}

enum _NodeKind { done, active, upcoming, declined }

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.kind,
    required this.title,
    required this.time,
    this.isLast = false,
  });

  final _NodeKind kind;
  final String title;
  final String time;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    Widget node() {
      switch (kind) {
        case _NodeKind.done:
          return _circle(scheme.primary,
              child: Icon(Icons.check, size: 14, color: scheme.onPrimary));
        case _NodeKind.active:
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: scheme.tertiaryContainer,
                  spreadRadius: 3,
                  blurRadius: 0,
                ),
              ],
            ),
            child: _circle(scheme.tertiary,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: scheme.onTertiary, shape: BoxShape.circle),
                )),
          );
        case _NodeKind.declined:
          return _circle(scheme.error,
              child: Icon(Icons.close, size: 14, color: scheme.onError));
        case _NodeKind.upcoming:
          return _circle(scheme.surfaceContainerHighest);
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              node(),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: scheme.outlineVariant),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.labelLarge),
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(time,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: AppTokens.tnum,
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(Color color, {Widget? child}) => Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: child,
      );
}

/// 140px clock progress ring — tertiary on tertiaryContainer (doc 02 §3.1).
class AwaitingRing extends StatefulWidget {
  const AwaitingRing({super.key});

  @override
  State<AwaitingRing> createState() => _AwaitingRingState();
}

class _AwaitingRingState extends State<AwaitingRing>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _ctrl?.dispose();
      _ctrl = null;
    } else {
      _ctrl ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 140.0;

    final clock = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer disc
          Container(
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          // inner disc with clock glyph
          Container(
            width: size - 36,
            height: size - 36,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: CustomPaint(painter: _ClockPainter(scheme.tertiary)),
          ),
          // 12 o'clock orbiting dot
          _ctrl == null
              ? _topDot(scheme)
              : AnimatedBuilder(
                  animation: _ctrl!,
                  builder: (_, child) => Transform.rotate(
                    angle: _ctrl!.value * 2 * math.pi,
                    child: child,
                  ),
                  child: _topDot(scheme),
                ),
        ],
      ),
    );

    return Semantics(
      liveRegion: true,
      label: 'Đang chờ chủ sân xác nhận',
      child: clock,
    );
  }

  Widget _topDot(ColorScheme scheme) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: scheme.tertiary, shape: BoxShape.circle),
        ),
      );
}

class _ClockPainter extends CustomPainter {
  _ClockPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width * 0.28;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, r, paint);
    // hands
    canvas.drawLine(center, center + Offset(0, -r * 0.6), paint);
    canvas.drawLine(center, center + Offset(r * 0.45, 0), paint);
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.color != color;
}
