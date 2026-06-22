import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/profile_models.dart';
import 'profile_section.dart';

/// "Thông tin liên hệ" — họ tên / SĐT / email / địa chỉ, all editable and all
/// opening the same edit dialog ([onEdit]).
class ContactSection extends StatelessWidget {
  const ContactSection({super.key, required this.profile, required this.onEdit});

  final OwnerProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      icon: Symbols.contact_page,
      title: 'Thông tin liên hệ',
      rows: [
        InfoRow(
          icon: Symbols.badge,
          label: 'Họ và tên',
          value: profile.name,
          editable: true,
          onTap: onEdit,
          semanticsLabel: 'profile-row-name',
        ),
        InfoRow(
          icon: Symbols.call,
          label: 'Số điện thoại',
          value: profile.phone,
          editable: true,
          onTap: onEdit,
          semanticsLabel: 'profile-row-phone',
        ),
        InfoRow(
          icon: Symbols.mail,
          label: 'Email',
          value: profile.email,
          editable: true,
          onTap: onEdit,
          semanticsLabel: 'profile-row-email',
        ),
        InfoRow(
          icon: Symbols.location_on,
          label: 'Địa chỉ liên hệ',
          value: profile.address,
          editable: true,
          onTap: onEdit,
          semanticsLabel: 'profile-row-address',
        ),
      ],
    );
  }
}

/// "Thông tin doanh nghiệp" — read-only, with a "Chi tiết" text action.
class BusinessSection extends StatelessWidget {
  const BusinessSection({
    super.key,
    required this.profile,
    required this.onDetails,
  });

  final OwnerProfile profile;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      icon: Symbols.business_center,
      title: 'Thông tin doanh nghiệp',
      trailing: TextButton.icon(
        onPressed: onDetails,
        icon: const Icon(Symbols.open_in_new, size: 16),
        label: const Text('Chi tiết'),
      ),
      rows: [
        InfoRow(
          icon: Symbols.storefront,
          label: 'Tên hộ kinh doanh',
          value: profile.bizName,
        ),
        InfoRow(
          icon: Symbols.tag,
          label: 'Mã số thuế',
          value: profile.taxCode,
          mono: true,
        ),
        InfoRow(
          icon: Symbols.map,
          label: 'Khu vực hoạt động',
          value: profile.bizArea,
        ),
      ],
    );
  }
}

/// "Tài khoản nhận tiền" — bank (+ "Đã liên kết" pill), masked account number,
/// and the editable account holder.
class PayoutSection extends StatelessWidget {
  const PayoutSection({
    super.key,
    required this.profile,
    required this.onChangeAccount,
  });

  final OwnerProfile profile;
  final VoidCallback onChangeAccount;

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      icon: Symbols.account_balance,
      title: 'Tài khoản nhận tiền',
      rows: [
        InfoRow(
          icon: Symbols.account_balance,
          label: 'Ngân hàng',
          value: profile.bankName,
          trailing: profile.payoutLinked
              ? const StatusPill(label: 'Đã liên kết', iconSize: 14)
              : null,
        ),
        InfoRow(
          icon: Symbols.credit_card,
          label: 'Số tài khoản',
          value: profile.accountMasked,
          mono: true,
        ),
        InfoRow(
          icon: Symbols.person,
          label: 'Chủ tài khoản',
          value: profile.accountHolder,
          mono: true,
          editable: true,
          onTap: onChangeAccount,
          semanticsLabel: 'profile-row-account-holder',
        ),
      ],
    );
  }
}

