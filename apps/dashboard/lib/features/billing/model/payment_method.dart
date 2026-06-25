import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The Vietnamese payment methods offered on the checkout screen.
enum PaymentMethodId { bank, momo, cash }

/// A payment method plus the method-specific details rendered in the detail
/// panel. Source of all copy/numbers: design handoff `billing-data.jsx`
/// (`PAY_METHODS`).
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
    required this.confirm,
    this.bank,
    this.account,
    this.holder,
    this.note,
    this.phone,
    this.address,
    this.hours,
  });

  final PaymentMethodId id;
  final String name; // "Chuyển khoản ngân hàng"
  final IconData icon;
  final String desc; // row subtitle
  final String confirm; // footer pay-button label

  // bank
  final String? bank; // "Vietcombank (VCB)"
  final String? account; // "0071 0007 89456"
  // bank + momo
  final String? holder; // "CT TNHH SPORTBUDDIES" / "SPORTBUDDIES"
  final String? note; // transfer memo "SNB 2608"
  // momo
  final String? phone; // "0901 234 567"
  // cash
  final String? address; // office address
  final String? hours; // opening hours

  bool get isCash => id == PaymentMethodId.cash;
  bool get isMomo => id == PaymentMethodId.momo;

  static const List<PaymentMethod> all = [
    PaymentMethod(
      id: PaymentMethodId.bank,
      name: 'Chuyển khoản ngân hàng',
      icon: Symbols.account_balance,
      desc: 'Quét VietQR hoặc chuyển thủ công',
      bank: 'Vietcombank (VCB)',
      account: '0071 0007 89456',
      holder: 'CT TNHH SPORTBUDDIES',
      note: 'SNB 2608',
      confirm: 'Tôi đã chuyển khoản',
    ),
    PaymentMethod(
      id: PaymentMethodId.momo,
      name: 'Ví MoMo',
      icon: Symbols.account_balance_wallet,
      desc: 'Quét mã trong ứng dụng MoMo',
      phone: '0901 234 567',
      holder: 'SPORTBUDDIES',
      note: 'SNB 2608',
      confirm: 'Tôi đã thanh toán MoMo',
    ),
    PaymentMethod(
      id: PaymentMethodId.cash,
      name: 'Tiền mặt',
      icon: Symbols.payments,
      desc: 'Nộp tại văn phòng SnB',
      address: '12 Nguyễn Lương Bằng, P. Tân Phú, Quận 7',
      hours: 'T2–T7, 8:00–17:30',
      confirm: 'Tôi sẽ nộp tiền mặt',
    ),
  ];
}
