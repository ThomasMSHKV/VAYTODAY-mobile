import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_dropdown_field.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_photo_picker.dart';
import 'package:VayToday/features/add_company/presentation/widgets/add_company_text_field.dart';

class AddCompanyScreen extends StatefulWidget {
  const AddCompanyScreen({super.key});

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  String? _selectedCategory;
  String? _selectedSubcategory;

  final Map<String, List<String>> _subcategoriesByCategory = const {
    'Медицина': [
      'Стоматология',
      'Остеопат',
      'Хирург',
      'Клиника',
      'Травматолог',
    ],
    'Строительство': ['Мастера', 'Плитка', 'Кирпичи', 'Ремонт', 'Сантехника'],
    'Кафе и рестораны': ['Кафе', 'Рестораны', 'Пекарни', 'Десерты'],
    'Красота': ['Визажист', 'Парикмахер', 'Ногти', 'Косметология'],
  };

  List<String> get _categories => _subcategoriesByCategory.keys.toList();

  List<String> get _subcategories {
    if (_selectedCategory == null) return [];
    return _subcategoriesByCategory[_selectedCategory] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            22,
            18,
            22,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.authText,
                      size: 26,
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Добавление компании',
                        style: TextStyle(
                          color: AppColors.authText,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 34),

              const AddCompanyTextField(
                label: 'Название компании',
                hintText: 'Введите название компании',
                icon: Icons.business_outlined,
              ),

              const SizedBox(height: 28),

              AddCompanyDropdownField(
                label: 'Категория',
                hintText: 'Выберите категорию',
                icon: Icons.grid_view_rounded,
                items: _categories,
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubcategory = null;
                  });
                },
              ),

              const SizedBox(height: 28),

              AddCompanyDropdownField(
                label: 'Подкатегория',
                hintText: _selectedCategory == null
                    ? 'Сначала выберите категорию'
                    : 'Выберите подкатегорию',
                icon: Icons.local_offer_outlined,
                items: _subcategories,
                value: _selectedSubcategory,
                onChanged: _selectedCategory == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedSubcategory = value;
                        });
                      },
              ),

              const SizedBox(height: 28),

              const AddCompanyTextField(
                label: 'Описание компании',
                hintText: 'Расскажите о вашей компании',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),

              const SizedBox(height: 28),

              const AddCompanyTextField(
                label: 'Адрес компании',
                hintText: 'Введите адрес компании',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 28),

              AddCompanyDropdownField(
                label: 'Время работы',
                hintText: 'Например: Пн — Вс: 09:00 — 20:00',
                icon: Icons.access_time_rounded,
                items: const [
                  'Пн — Пт: 09:00 — 18:00',
                  'Пн — Сб: 09:00 — 20:00',
                  'Пн — Вс: 09:00 — 20:00',
                  'Круглосуточно',
                ],
                value: null,
                onChanged: (_) {},
              ),

              const SizedBox(height: 28),

              AddCompanyPhotoPicker(onTap: () {}),

              const SizedBox(height: 34),

              SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.authText,
                    size: 28,
                  ),
                  label: const Text(
                    'Добавить компанию',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.authGold,
                    elevation: 6,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
