import 'package:VayToday/features/other/presentation/screens/about_app_screen.dart';
import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/other/presentation/widgets/other_menu_item.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  final ProfileRepository _profileRepository = ProfileRepository();
  final CompanyManagementRepository _companyManagementRepository =
      CompanyManagementRepository();

  bool _isDeletingAccount = false;

  Future<void> _confirmDeleteAccount() async {
    if (_isDeletingAccount) return;

    setState(() => _isDeletingAccount = true);

    var hasCompanies = false;
    try {
      hasCompanies =
          (await _companyManagementRepository.getMyCompanies()).isNotEmpty;
    } catch (_) {
      hasCompanies = (await _companyManagementRepository.getCachedMyCompanies())
          .isNotEmpty;
    }

    if (!mounted) return;
    setState(() => _isDeletingAccount = false);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(hasCompanies: hasCompanies),
    );

    if (shouldDelete != true || !mounted) return;

    setState(() => _isDeletingAccount = true);

    try {
      await _profileRepository.deleteAccount();
      await _companyManagementRepository.clearCurrentAccountCache();
      await _sessionStorage.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Аккаунт удален')));
      Navigator.of(context).pop(true);
    } on ProfileApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить аккаунт')),
      );
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

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

              OtherMenuItem(
                title: 'Удалить аккаунт',
                backgroundColor: const Color(0xFFFFEAED),
                textColor: AppColors.error,
                onTap: _confirmDeleteAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatelessWidget {
  final bool hasCompanies;

  const _DeleteAccountDialog({required this.hasCompanies});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Удалить аккаунт?',
        style: TextStyle(
          color: AppColors.authText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        hasCompanies
            ? 'Все ваши компании удалятся вместе со всем ассортиментом, отзывами и рейтингом. Вы уверены, что хотите удалить аккаунт?'
            : 'Вы уверены, что хотите удалить аккаунт? Это действие нельзя отменить.',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.detailTextGreen,
          ),
          child: const Text(
            'Отмена',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text(
            'Удалить',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
