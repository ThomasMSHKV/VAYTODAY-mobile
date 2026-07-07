import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/presentation/cubit/auth_status_cubit.dart';
import 'package:VayToday/features/auth/presentation/cubit/auth_status_state.dart';
import 'package:VayToday/features/auth/presentation/screens/login_screen.dart';

typedef AuthRequiredActionBuilder =
    Widget Function(BuildContext context, VoidCallback onTap, bool isChecking);

class AuthRequiredAction extends StatelessWidget {
  final String dialogMessage;
  final VoidCallback onAuthorized;
  final AuthRequiredActionBuilder builder;

  const AuthRequiredAction({
    super.key,
    required this.dialogMessage,
    required this.onAuthorized,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthStatusCubit(AuthSessionStorage()),
      child: _AuthRequiredActionView(
        dialogMessage: dialogMessage,
        onAuthorized: onAuthorized,
        builder: builder,
      ),
    );
  }
}

class _AuthRequiredActionView extends StatelessWidget {
  final String dialogMessage;
  final VoidCallback onAuthorized;
  final AuthRequiredActionBuilder builder;

  const _AuthRequiredActionView({
    required this.dialogMessage,
    required this.onAuthorized,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthStatusCubit, AuthStatusState>(
      listener: (context, state) {
        if (state is AuthStatusAuthorized) {
          onAuthorized();
        }

        if (state is AuthStatusUnauthorized) {
          _showUnauthorizedDialog(context);
        }
      },
      builder: (context, state) {
        return builder(
          context,
          context.read<AuthStatusCubit>().checkAuthorization,
          state is AuthStatusChecking,
        );
      },
    );
  }

  void _showUnauthorizedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Вы не авторизованы',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(dialogMessage, style: const TextStyle(height: 1.4)),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.favoriteYellow,
                  foregroundColor: AppColors.authBlack,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Авторизоваться',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
