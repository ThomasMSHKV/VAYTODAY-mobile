import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class CompanyDetailBottomBar extends StatelessWidget {
  final VoidCallback onMapTap;
  final VoidCallback onMessageTap;

  const CompanyDetailBottomBar({
    super.key,
    required this.onMapTap,
    required this.onMessageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        color: AppColors.screenBackground,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: onMapTap,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.detailTextGreen,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Показать на карте',
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.detailTextGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onMessageTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonYellow,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Написать',
                    style: TextStyle(
                      color: AppColors.detailTextGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
