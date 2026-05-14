import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/other/presentation/screens/privacy_policy_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
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
                        'О приложении',
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

              const SizedBox(height: 50),

              SvgPicture.asset(
                'assets/icons/white_logo.svg',
                width: 90,
                height: 90,
              ),

              const SizedBox(height: 52),

              const Text(
                'Мы собрали компании и услуги\n'
                'в одном приложении. Удобный и понятный\n'
                'интерфейс поможет пользователям находить\n'
                'услуги по категориям, сохранять понравившиеся\n'
                'компании и оставаться с ними на связи.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.authText,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Версия программы:  1.11',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Разработчики: «Раута»',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 44),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Политика конфиденциальности',
                  style: TextStyle(
                    color: AppColors.authText,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
