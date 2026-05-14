import 'package:VayToday/features/other/presentation/screens/about_app_screen.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/other/presentation/widgets/other_menu_item.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                      color: AppColors.authText,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Прочее',
                        style: TextStyle(
                          color: AppColors.authText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),

              const SizedBox(height: 30),

              OtherMenuItem(
                title: 'О приложении',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              OtherMenuItem(title: 'Поддержка', onTap: () {}),

              const SizedBox(height: 20),

              OtherMenuItem(title: 'О сотрудничестве', onTap: () {}),

              const SizedBox(height: 20),

              OtherMenuItem(title: 'Удалить аккаунт', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
