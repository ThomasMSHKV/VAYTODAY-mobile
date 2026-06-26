import 'package:flutter/material.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/add_company/presentation/screens/add_company_screen.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_required_action.dart';

class AddCompanyButton extends StatelessWidget {
  const AddCompanyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthRequiredAction(
      dialogMessage: 'Чтобы добавить компанию, необходимо войти в аккаунт.',
      onAuthorized: () {
        final navigator = Navigator.of(context);
        navigator.push(
          MaterialPageRoute(builder: (_) => const AddCompanyScreen()),
        );
      },
      builder: (context, onTap, isChecking) {
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isChecking ? null : onTap,
          child: Ink(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.favoriteYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isChecking
                ? const Padding(
                    padding: EdgeInsets.all(17),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add, size: 30, color: Color(0xFF45524A)),
          ),
        );
      },
    );
  }
}
