// Profile feature — screen widget.
//
// Shows the current user's avatar, full_name, phone, and email.
// Accessible via the '/profile' route registered in app_router.dart.
//
// The screen reads from [ProfileCubit] via BlocBuilder:
//   - ProfileLoading → CircularProgressIndicator
//   - ProfileLoaded  → avatar + fields
//   - ProfileError   → error text

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
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileLoaded(:final fullName, :final phone, :final email, :final avatarUrl) =>
              _ProfileBody(
                fullName: fullName,
                phone: phone,
                email: email,
                avatarUrl: avatarUrl,
              ),
            ProfileError(:final message) => Center(
                child: Text(message),
              ),
          };
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
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
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, size: 52)
                : null,
          ),
          const SizedBox(height: 32),
          _ProfileField(
            label: 'Full name',
            value: fullName,
            textStyle: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _ProfileField(
            label: 'Phone',
            value: phone,
            textStyle: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _ProfileField(
            label: 'Email',
            value: email,
            readOnly: true,
            textStyle: textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.readOnly = false,
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
