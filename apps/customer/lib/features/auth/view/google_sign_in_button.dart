// GoogleSignInButton — CAPP-011 / grava-144f.2.1
//
// Renders a "Sign in with Google" button that dispatches
// [GoogleSignInRequested] to the nearest [AuthBloc].
//
// Handles:
//   - AuthLoading  → shows CircularProgressIndicator, disables button
//   - AuthSuccess  → navigates to '/' via go_router
//   - AuthFailureState → shows SnackBar with error message

import 'package:customer/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// A button that initiates Google OAuth sign-in.
///
/// Must be placed inside a widget tree that provides [AuthBloc] via
/// [BlocProvider] (e.g. from the router or a parent widget).
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthSuccess || current is AuthFailureState,
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/');
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      buildWhen: (previous, current) =>
          current is AuthLoading ||
          current is AuthInitial ||
          current is AuthSuccess ||
          current is AuthFailureState,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return ElevatedButton(
          key: const Key('googleSignInButton'),
          onPressed: isLoading
              ? null
              : () => context
                  .read<AuthBloc>()
                  .add(const GoogleSignInRequested()),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in with Google'),
        );
      },
    );
  }
}
