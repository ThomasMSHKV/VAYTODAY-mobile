import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/core/utils/privacy_policy_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 44),
              SvgPicture.asset(
                'assets/icons/white_logo.svg',
                width: 90,
                height: 90,
              ),
              const SizedBox(height: 38),
              const Text(
                'VayToday',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.authText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'VayToday - город услуг в твоем телефоне. Здесь можно найти компанию рядом, посмотреть фото, прочитать описание, открыть адрес и связаться с бизнесом внутри приложения.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.authText,
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Для бизнеса это простой способ добавить компанию, показать ассортимент и получать клиентов напрямую.',
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
                'Версия приложения: 1.11',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Разработчик: VayToday',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 34),
              GestureDetector(
                onTap: () => openPrivacyPolicy(context),
                child: const Text(
                  'Политика конфиденциальности',
                  style: TextStyle(
                    color: AppColors.authText,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
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
