import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../model/invoice.dart';
import '../model/payment_method.dart';
import '../repository/billing_repository.dart';
import '../util/billing_format.dart';
import 'widgets/method_detail.dart';

/// Opens the "Cổng thanh toán" checkout as a modal dialog over the dashboard
/// (M3 dialog presentation mode). Returns when dismissed.
Future<void> showCheckoutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => BlocProvider(
      create: (_) => CheckoutCubit(repository: sl<BillingRepository>()),
      child: const CheckoutDialog(),
    ),
  );
}

class CheckoutDialog extends StatelessWidget {
  const CheckoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxH = MediaQuery.sizeOf(context).height - 112;
    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(32),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxH),
        child: BlocBuilder<CheckoutCubit, CheckoutState>(
          builder: (context, state) =>
              state.done ? _SuccessView(state: state) : _FormView(state: state),
        ),
      ),
    );
  }
}

// ── Payment form ───────────────────────────────────────────────
class _FormView extends StatelessWidget {
  const _FormView({required this.state});

  final CheckoutState state;

  void _copy(BuildContext context, String value) {
    Clipboard.setData(
        ClipboardData(text: value.replaceAll(RegExp(r'\s'), '')));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Đã sao chép: $value')));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CheckoutCubit>();
    final method = state.selectedMethod;
    final amount = state.invoice.amount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Summary(invoice: state.invoice),
                      const SizedBox(height: 22),
                      const _SectionLabel('Chọn phương thức thanh toán'),
                      const SizedBox(height: 10),
                      for (final m in state.methods) ...[
                        _MethodTile(
                          method: m,
                          selected: m.id == state.selected,
                          onTap: () => cubit.select(m.id),
                        ),
                        if (m.id != state.methods.last.id)
                          const SizedBox(height: 10),
                      ],
                      MethodDetail(
                        method: method,
                        amount: amount,
                        onCopy: (v) => _copy(context, v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _Footer(
          method: method,
          amount: amount,
          submitting: state.submitting,
          onPay: cubit.pay,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Quay lại',
              icon: const Icon(Symbols.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
            Text(
              'Thanh toán hoá đơn',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Symbols.lock, size: 15, fill: 1, color: scheme.primary),
            const SizedBox(width: 4),
            Text(
              'Bảo mật',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final amount = fmtVnd(invoice.amount);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.planName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.period,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã hoá đơn',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                invoice.id,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: scheme.outlineVariant),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Tổng cộng (đã gồm VAT)',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                amount,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: scheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method.icon,
                  size: 22,
                  color: selected
                      ? scheme.primaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      method.desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _Radio(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.primary : scheme.outline,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary,
                ),
              ),
            )
          : null,
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.method,
    required this.amount,
    required this.submitting,
    required this.onPay,
  });

  final PaymentMethod method;
  final int amount;
  final bool submitting;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Số tiền',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  fmtVnd(amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: submitting ? null : onPay,
              icon: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Symbols.lock, size: 18, fill: 1),
              label: Text(method.confirm),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success / pending ──────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warn = theme.extension<SnbColors>()!;
    final method = state.selectedMethod;
    final pending = state.outcome == PaymentOutcome.pending;

    final body = method.isCash
        ? 'Đã giữ chỗ kỳ này. Vui lòng nộp tiền mặt tại văn phòng để hoàn tất.'
        : pending
            ? 'Chúng tôi đang đối soát giao dịch. Hoá đơn sẽ cập nhật ngay khi nhận được tiền.'
            : 'Cảm ơn bạn! Gói Chuyên nghiệp đã được gia hạn. Biên lai đã gửi qua email.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pending ? warn.warnContainer : scheme.primaryContainer,
            ),
            child: Icon(
              pending ? Symbols.hourglass_top : Symbols.check,
              fill: 1,
              size: 46,
              color: pending ? warn.onWarnContainer : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            pending ? 'Đang chờ xác nhận' : 'Thanh toán thành công',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            fmtVnd(state.invoice.amount),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.invoice.id} · ${method.name}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.5,
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Symbols.receipt_long, size: 18),
            label: const Text('Về trang Thanh toán'),
          ),
        ],
      ),
    );
  }
}
