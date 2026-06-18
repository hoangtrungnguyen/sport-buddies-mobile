// Bottom sheet for editing the user's personal info (name/phone).
// Extracted from profile_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../profile_cubit.dart';
import '../profile_state.dart';

class EditPersonalInfoSheet extends StatefulWidget {
  const EditPersonalInfoSheet({
    super.key,
    required this.currentName,
    required this.currentPhone,
  });

  final String currentName;
  final String currentPhone;

  @override
  State<EditPersonalInfoSheet> createState() => _EditPersonalInfoSheetState();
}

class _EditPersonalInfoSheetState extends State<EditPersonalInfoSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _phoneCtrl = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profilePersonalInfo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('editNameField'),
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.labelFullName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('editPhoneField'),
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: '0901 234 567',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final isSaving = state is ProfileSaving;
                return FilledButton(
                  key: const Key('saveProfileButton'),
                  onPressed: isSaving
                      ? null
                      : () {
                          final name = _nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          context.read<ProfileCubit>().updateProfile(
                            name: name,
                            phone: _phoneCtrl.text.trim(),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
