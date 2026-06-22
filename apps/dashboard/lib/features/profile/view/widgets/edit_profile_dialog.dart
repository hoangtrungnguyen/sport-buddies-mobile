import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../model/profile_models.dart';

/// "Chỉnh sửa hồ sơ" dialog — edits a draft copy of [profile]; Huỷ discards.
/// Resolves to the patched [OwnerProfile] on save, or null on dismiss/cancel.
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key, required this.profile});

  final OwnerProfile profile;

  static Future<OwnerProfile?> show(
    BuildContext context,
    OwnerProfile profile,
  ) {
    return showDialog<OwnerProfile>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => EditProfileDialog(profile: profile),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.profile.name);
  late final TextEditingController _phone =
      TextEditingController(text: widget.profile.phone);
  late final TextEditingController _email =
      TextEditingController(text: widget.profile.email);
  late final TextEditingController _address =
      TextEditingController(text: widget.profile.address);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final draft = widget.profile.copyWith(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa hồ sơ'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                controller: _name,
                label: 'Họ và tên',
                icon: Symbols.badge,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _phone,
                label: 'Số điện thoại',
                icon: Symbols.call,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _field(
                controller: _email,
                label: 'Email',
                icon: Symbols.mail,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Bắt buộc';
                  if (!s.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _field(
                controller: _address,
                label: 'Địa chỉ liên hệ',
                icon: Symbols.location_on,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Huỷ'),
        ),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Symbols.check, size: 18),
          label: const Text('Lưu'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}
