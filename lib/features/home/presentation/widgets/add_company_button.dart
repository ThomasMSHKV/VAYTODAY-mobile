import 'package:flutter/material.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/presentation/screens/login_screen.dart';

class AddCompanyButton extends StatelessWidget {
  const AddCompanyButton({super.key});

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
          content: const Text(
            'Чтобы добавить компанию, необходимо войти в аккаунт.',
            style: TextStyle(height: 1.4),
          ),
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showUnauthorizedDialog(context),
      child: Ink(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.favoriteYellow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, size: 30, color: Color(0xFF45524A)),
      ),
    );
  }
}
