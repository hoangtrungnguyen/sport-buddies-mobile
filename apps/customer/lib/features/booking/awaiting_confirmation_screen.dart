import 'package:customer/features/booking/booking_stepper.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_cubit.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AwaitingConfirmationScreen extends StatefulWidget {
  const AwaitingConfirmationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<AwaitingConfirmationScreen> createState() =>
      _AwaitingConfirmationScreenState();
}

class _AwaitingConfirmationScreenState
    extends State<AwaitingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    context.read<AwaitingConfirmationCubit>().load(widget.bookingId);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AwaitingConfirmationCubit, AwaitingState>(
      listener: (context, state) {
        if (state is AwaitingConfirmed) {
          context.go('/booking/payment/${state.slotId}');
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Chờ xác nhận'),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: switch (state) {
          AwaitingLoading() ||
          AwaitingInitial() =>
            const Center(child: CircularProgressIndicator()),
          AwaitingError(:final message) =>
            Center(child: Text(message, style: const TextStyle(color: Colors.red))),
          AwaitingConfirmed() =>
            const Center(child: CircularProgressIndicator()),
          AwaitingLoaded() =>
            _LoadedBody(
              state: state,
              pulseAnim: _pulseAnim,
            ),
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state, required this.pulseAnim});

  final AwaitingLoaded state;
  final Animation<double> pulseAnim;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat('EEE, dd/MM', 'vi');

  @override
  Widget build(BuildContext context) {
    final shortId = state.bookingId.split('-').first.toUpperCase();

    return Column(
      children: [
        const BookingStepper(step: 2),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              children: [
                // Pulsing clock ring
                ScaleTransition(
                  scale: pulseAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF9C3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 104,
                        height: 104,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          size: 52,
                          color: Color(0xFFCA8A04),
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Color(0xFFCA8A04),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Chờ chủ sân xác nhận',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yêu cầu đặt sân đã được gửi đến chủ sân.\nBạn sẽ được thông báo khi có kết quả.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 32),
                // Booking detail card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Mã đặt sân',
                        value: shortId,
                        valueStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(label: 'Sân', value: state.courtName),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Thời gian',
                        value:
                            '${_timeFmt.format(state.slotStart)} – ${_timeFmt.format(state.slotEnd)}',
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        label: 'Ngày',
                        value: _dateFmt.format(state.slotStart),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Color(0xFFCA8A04)),
                            SizedBox(width: 5),
                            Text(
                              'Chờ xác nhận',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _TimelineSection(submittedAt: state.slotStart),
              ],
            ),
          ),
        ),
        // Escape hatch — always visible
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: OutlinedButton(
            onPressed: () => context.go('/bookings/upcoming'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Xem lịch đặt',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
        ),
      ],
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.submittedAt});

  final DateTime submittedAt;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineItem(
          done: true,
          label: 'Bạn gửi yêu cầu đặt sân',
          time: _timeFmt.format(submittedAt),
        ),
        _TimelineItem(
          active: true,
          label: 'Chờ chủ sân phản hồi...',
          time: 'đang chờ',
        ),
        _TimelineItem(
          label: 'Đặt sân được xác nhận',
          time: '',
          isLast: true,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.time,
    this.done = false,
    this.active = false,
    this.isLast = false,
  });

  final String label;
  final String time;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = done
        ? const Color(0xFF16A34A)
        : active
            ? const Color(0xFFCA8A04)
            : const Color(0xFFE5E7EB);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: active
                      ? Border.all(color: const Color(0xFFFEF9C3), width: 3)
                      : null,
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : active
                        ? const Center(
                            child: SizedBox(
                              width: 6,
                              height: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          )
                        : null,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 32,
                  color: const Color(0xFFE5E7EB),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: done || active
                        ? const Color(0xFF111827)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

