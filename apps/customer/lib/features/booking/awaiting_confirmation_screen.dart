import 'package:customer/features/booking/state/awaiting_confirmation_cubit.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_state.dart';
import 'package:customer/features/booking/widgets/awaiting_loaded_body.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AwaitingConfirmationScreen extends StatefulWidget {
  const AwaitingConfirmationScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<AwaitingConfirmationScreen> createState() =>
      _AwaitingConfirmationScreenState();
}

class _AwaitingConfirmationScreenState extends State<AwaitingConfirmationScreen>
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
    _pulseAnim = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
          title: Text(AppLocalizations.of(context).bookingStatusPendingHost),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/bookings/upcoming');
              }
            },
          ),
        ),
        body: switch (state) {
          AwaitingLoading() ||
          AwaitingInitial() => const Center(child: CircularProgressIndicator()),
          AwaitingError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
          AwaitingConfirmed() => const Center(
            child: CircularProgressIndicator(),
          ),
          AwaitingLoaded() => LoadedBody(state: state, pulseAnim: _pulseAnim),
        },
      ),
    );
  }
}
