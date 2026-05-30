import 'package:customer/features/booking/state/payment_cubit.dart';
import 'package:customer/features/booking/state/payment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) => switch (state) {
        PaymentLoading() => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        PaymentError(:final message) => Scaffold(
            body: Center(
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
          ),
        PaymentLoaded() => _LoadedScreen(state: state),
      },
    );
  }
}

class _LoadedScreen extends StatelessWidget {
  const _LoadedScreen({required this.state});

  final PaymentLoaded state;

  static final _timeFmt = DateFormat('HH:mm');
  static final _dateFmt = DateFormat('EEE, dd/MM/yyyy', 'vi');
  static final _priceFmt = NumberFormat('#,###', 'vi');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const _StepperRow(step: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đặt sân thành công!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng thanh toán tại sân khi đến.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),
                  // Booking breakdown card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _Row(label: 'Sân', value: state.courtName),
                        const _Divider(),
                        _Row(
                          label: 'Thời gian',
                          value:
                              '${_timeFmt.format(state.slotStart)} – ${_timeFmt.format(state.slotEnd)}',
                        ),
                        const _Divider(),
                        _Row(
                          label: 'Ngày',
                          value: _dateFmt.format(state.slotStart),
                        ),
                        const _Divider(),
                        _Row(
                          label: 'Tổng tiền',
                          value: '${_priceFmt.format(state.totalPrice)} VNĐ',
                          valueStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                        const _Divider(),
                        const _Row(
                          label: 'Thanh toán',
                          value: 'Tại sân (tiền mặt)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Cash notice
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.wallet_rounded,
                          size: 20,
                          color: Color(0xFFB45309),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Nhớ mang tiền mặt khi đến sân!',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                FilledButton(
                  onPressed: () =>
                      context.go('/bookings/${state.bookingId}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF16A34A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Xem lịch đặt của tôi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: Color(0xFFE5E7EB)),
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
