import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AddCompanyPhotoPicker extends StatelessWidget {
  final VoidCallback onTap;

  const AddCompanyPhotoPicker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Фотографии компании (до 4 фото)',
          style: TextStyle(
            color: AppColors.authText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.divider,
                width: 1.2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.authGold,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  'Добавить фотографии',
                  style: TextStyle(
                    color: AppColors.authText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Нажмите, чтобы выбрать фото из галереи\nМожно загрузить до 4 фотографий',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
