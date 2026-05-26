// Profile feature — screen widget.
//
// Shows the current user's avatar, full_name (editable), phone, and email.
// Accessible via the '/profile' route registered in app_router.dart.
//
// The screen reads from [ProfileCubit] via BlocConsumer:
//   - ProfileLoading     → CircularProgressIndicator
//   - ProfileLoaded      → avatar + editable full_name field + read-only fields
//   - ProfileError       → error text
//   - ProfileSaving      → shows saving indicator in place of Save button
//   - ProfileUpdateError → error SnackBar; reverts to loaded view

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'profile_cubit.dart';
import 'profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Only load when the cubit is still in the initial loading state (i.e. not
    // pre-seeded by a test via ProfileCubit.fake).
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is ProfileLoading) {
      cubit.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            current is ProfileUpdateError ||
            (previous is ProfileSaving && current is ProfileLoaded),
        listener: (context, state) {
          if (state is ProfileUpdateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ProfileLoaded) {
            // Previous state was ProfileSaving → save succeeded.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully.'),
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          // Show the ProfileLoaded UI again after a ProfileUpdateError so the
          // user can retry — we keep showing the loaded body.
          return current is! ProfileUpdateError;
        },
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileSaving() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileLoaded(
              :final fullName,
              :final phone,
              :final email,
              :final avatarUrl
            ) =>
              _ProfileBody(
                fullName: fullName,
                phone: phone,
                email: email,
                avatarUrl: avatarUrl,
              ),
            ProfileError(:final message) => Center(
                child: Text(message),
              ),
            // ProfileUpdateError is handled in listener; builder ignores it via
            // buildWhen — but sealed class exhaustiveness requires a branch.
            ProfileUpdateError() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ProfileBody — editable form with Save button
// ---------------------------------------------------------------------------

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({
    required this.fullName,
    required this.phone,
    required this.email,
    this.avatarUrl,
  });

  final String fullName;
  final String phone;
  final String email;
  final String? avatarUrl;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
  }

  @override
  void didUpdateWidget(_ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullName != widget.fullName) {
      // Sync controller when cubit emits a new ProfileLoaded after a save.
      _nameController.text = widget.fullName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    context.read<ProfileCubit>().updateFullName(name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 52,
            backgroundImage:
                widget.avatarUrl != null
                    ? NetworkImage(widget.avatarUrl!)
                    : null,
            child: widget.avatarUrl == null
                ? const Icon(Icons.person, size: 52)
                : null,
          ),
          const SizedBox(height: 32),
          // Editable full_name field.
          TextFormField(
            key: const Key('fullNameField'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full name',
              border: OutlineInputBorder(),
            ),
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _ProfileField(
            label: 'Phone',
            value: widget.phone,
            textStyle: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _ProfileField(
            label: 'Email',
            value: widget.email,
            readOnly: true,
            textStyle: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('saveButton'),
              onPressed: () => _onSave(context),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _ProfileField — simple read-only display field
// ---------------------------------------------------------------------------

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.readOnly = true,
    this.textStyle,
  });

  final String label;
  final String value;
  final bool readOnly;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      style: textStyle,
    );
  }
}
