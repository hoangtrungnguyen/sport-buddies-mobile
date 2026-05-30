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
          context.go('/booking/access-control/${state.slotId}');
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
        const _StepperRow(step: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pulsing icon
                ScaleTransition(
                  scale: pulseAnim,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9C3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFDE047),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 48,
                      color: Color(0xFFCA8A04),
                    ),
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
                        child: const Text(
                          'Chờ chủ sân xác nhận',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Escape hatch — always visible
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: OutlinedButton(
            onPressed: () => context.go('/'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Về bản đồ',
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

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final isActive = i == step;
          final isDone = i < step;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF16A34A)
                  : isDone
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }
}
