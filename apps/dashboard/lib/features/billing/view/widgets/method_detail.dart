import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/payment_method.dart';
import '../../util/billing_format.dart';
import 'faux_qr.dart';

/// Per-method detail panel (`.co-detail`): QR + copyable fields for bank/MoMo,
/// or the numbered cash instructions. [onCopy] receives the raw value.
class MethodDetail extends StatelessWidget {
  const MethodDetail({
    super.key,
    required this.method,
    required this.amount,
    required this.onCopy,
  });

  final PaymentMethod method;
  final int amount;
  final ValueChanged<String> onCopy;

  static const _momoColor = Color(0xFFA50064);
  static const _bankQrColor = Color(0xFF101F0F);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: method.isCash ? _cash(context) : _transfer(context),
    );
  }

  // ── Bank / MoMo ──────────────────────────────────────────────
  Widget _transfer(BuildContext context) {
    final fields = method.isMomo
        ? <Widget>[
            _CopyField(label: 'Số điện thoại', value: method.phone!, mono: true, onCopy: onCopy),
            _CopyField(label: 'Người nhận', value: method.holder!, onCopy: onCopy),
            _CopyField(label: 'Nội dung', value: method.note!, mono: true, onCopy: onCopy),
          ]
        : <Widget>[
            _CopyField(label: 'Ngân hàng', value: method.bank!, onCopy: onCopy),
            _CopyField(label: 'Số tài khoản', value: method.account!, mono: true, onCopy: onCopy),
            _CopyField(label: 'Chủ tài khoản', value: method.holder!, onCopy: onCopy),
            _CopyField(label: 'Nội dung CK', value: method.note!, mono: true, onCopy: onCopy),
          ];

    final qr = _QrBlock(
      color: method.isMomo ? _momoColor : _bankQrColor,
      seed: method.isMomo ? 23 : 8,
      caption: method.isMomo ? 'Quét bằng app MoMo' : 'Quét bằng app ngân hàng',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2-col on wide, stacked (QR on top) under 600px.
        LayoutBuilder(
          builder: (context, c) {
            final amountField = _CopyField(
              label: 'Số tiền',
              value: fmtVnd(amount),
              mono: true,
              valueColor: Theme.of(context).colorScheme.primary,
              onCopy: onCopy,
            );
            final fieldCol = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...fields, amountField],
            );
            if (c.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [qr, const SizedBox(height: 16), fieldCol],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                qr,
                const SizedBox(width: 24),
                Expanded(child: fieldCol),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        const _Note(
          'Giữ đúng nội dung chuyển khoản để hệ thống tự động đối soát. '
          'Đối soát thường trong 1–2 phút.',
        ),
      ],
    );
  }

  // ── Cash ─────────────────────────────────────────────────────
  Widget _cash(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CashStep(1, [
          const TextSpan(text: 'Mang đủ '),
          TextSpan(text: fmtVnd(amount), style: _bold),
          const TextSpan(text: ' tiền mặt cùng mã hoá đơn '),
          const TextSpan(text: 'SNB-2608', style: _bold),
          const TextSpan(text: '.'),
        ]),
        _CashStep(2, [
          const TextSpan(text: 'Nộp tại văn phòng SnB — '),
          TextSpan(text: method.address, style: _bold),
          TextSpan(text: ' (${method.hours}).'),
        ]),
        _CashStep(3, [
          const TextSpan(text: 'Nhân viên xác nhận, hoá đơn chuyển sang '),
          const TextSpan(text: 'Đã thanh toán', style: _bold),
          const TextSpan(text: ' trong vài phút.'),
        ]),
        const SizedBox(height: 14),
        _Note(
          'Bấm “${method.confirm}” để giữ chỗ kỳ này; '
          'gói vẫn hoạt động trong thời gian chờ nộp.',
        ),
      ],
    );
  }

  static const _bold = TextStyle(fontWeight: FontWeight.w700);
}

class _QrBlock extends StatelessWidget {
  const _QrBlock({required this.color, required this.seed, required this.caption});

  final Color color;
  final int seed;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
              BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
            ],
          ),
          child: FauxQr(size: 132, seed: seed, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          caption,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CopyField extends StatelessWidget {
  const _CopyField({
    required this.label,
    required this.value,
    required this.onCopy,
    this.mono = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final ValueChanged<String> onCopy;
  final bool mono;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: 'Sao chép',
            color: scheme.onSurfaceVariant,
            onPressed: () => onCopy(value),
            icon: const Icon(Symbols.content_copy),
          ),
        ],
      ),
    );
  }
}

class _CashStep extends StatelessWidget {
  const _CashStep(this.n, this.spans);

  final int n;
  final List<InlineSpan> spans;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$n',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
                  children: spans,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Symbols.info, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
