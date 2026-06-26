import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AddCompanyDropdownOption {
  final String value;
  final String label;

  const AddCompanyDropdownOption({required this.value, required this.label});
}

class AddCompanyDropdownField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final List<AddCompanyDropdownOption> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  const AddCompanyDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.authText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.authGold, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    hint: Text(
                      hintText,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.authText,
                      size: 30,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: AppColors.authText,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
