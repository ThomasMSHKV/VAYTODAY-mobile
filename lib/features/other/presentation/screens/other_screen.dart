import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/companies/data/company_management_repository.dart';
import 'package:VayToday/features/other/presentation/screens/about_app_screen.dart';
import 'package:VayToday/features/other/presentation/widgets/other_menu_item.dart';
import 'package:VayToday/features/profile/data/profile_repository.dart';

const _otherTitle = '\u041f\u0440\u043e\u0447\u0435\u0435';
const _aboutAppTitle =
    '\u041e \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u0438';
const _faqTitle =
    '\u0427\u0430\u0441\u0442\u044b\u0435 \u0432\u043e\u043f\u0440\u043e\u0441\u044b';
const _contactsTitle = '\u041a\u043e\u043d\u0442\u0430\u043a\u0442\u044b';
const _deleteAccountTitle =
    '\u0423\u0434\u0430\u043b\u0438\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442';
const _closeTitle = '\u0417\u0430\u043a\u0440\u044b\u0442\u044c';
const _cancelTitle = '\u041e\u0442\u043c\u0435\u043d\u0430';
const _deleteTitle = '\u0423\u0434\u0430\u043b\u0438\u0442\u044c';
const _accountDeletedMessage =
    '\u0410\u043a\u043a\u0430\u0443\u043d\u0442 \u0443\u0434\u0430\u043b\u0435\u043d';
const _accountDeleteFailedMessage =
    '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u0443\u0434\u0430\u043b\u0438\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442';

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

  void _showFaqDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => const _InfoDialog(title: _faqTitle, child: _FaqContent()),
    );
  }

  void _showContactsDialog() {
    showDialog<void>(
      context: context,
      builder: (_) =>
          const _InfoDialog(title: _contactsTitle, child: _ContactsContent()),
    );
  }

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
      ).showSnackBar(const SnackBar(content: Text(_accountDeletedMessage)));
      Navigator.of(context).pop(true);
    } on ProfileApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_accountDeleteFailedMessage)),
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
                        _otherTitle,
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
                title: _aboutAppTitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              OtherMenuItem(title: _faqTitle, onTap: _showFaqDialog),
              const SizedBox(height: 20),
              OtherMenuItem(title: _contactsTitle, onTap: _showContactsDialog),
              const SizedBox(height: 20),
              OtherMenuItem(
                title: _deleteAccountTitle,
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

class _InfoDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.authText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.68,
          maxWidth: 420,
        ),
        child: SingleChildScrollView(child: child),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.detailTextGreen,
          ),
          child: const Text(
            _closeTitle,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _FaqContent extends StatelessWidget {
  const _FaqContent();

  @override
  Widget build(BuildContext context) {
    return const SelectableText(
      '\u041a\u0430\u043a \u043f\u043e\u0434\u043d\u044f\u0442\u044c \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u044e \u0432 \u0440\u0435\u0439\u0442\u0438\u043d\u0433\u0435?\n\n'
      '\u041d\u0430\u0448\u0435 \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u0435 \u043f\u0440\u0435\u0434\u043e\u0441\u0442\u0430\u0432\u043b\u044f\u0435\u0442 \u043d\u0435\u0441\u043a\u043e\u043b\u044c\u043a\u043e \u0432\u0430\u0440\u0438\u0430\u043d\u0442\u043e\u0432 \u0434\u043b\u044f \u0440\u0430\u0437\u0432\u0438\u0442\u0438\u044f \u0432\u0430\u0448\u0435\u0433\u043e \u0431\u0438\u0437\u043d\u0435\u0441\u0430:\n\n'
      '1) \u0412\u044b \u043c\u043e\u0436\u0435\u0442\u0435 \u0440\u0430\u0437\u043c\u0435\u0441\u0442\u0438\u0442\u044c \u0441\u0432\u043e\u044e \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u044e \u043d\u0430 \u0433\u043b\u0430\u0432\u043d\u043e\u0439 \u0441\u0442\u0440\u0430\u043d\u0438\u0446\u0435 \u043d\u0430 \u0446\u0435\u043d\u0442\u0440\u0430\u043b\u044c\u043d\u043e\u043c \u0431\u0430\u043d\u043d\u0435\u0440\u0435 \u0432 \u0440\u0430\u0437\u0434\u0435\u043b\u0435 \u0440\u0435\u043a\u043e\u043c\u0435\u043d\u0434\u0430\u0446\u0438\u0438.\n\n'
      '2) \u0412\u044b \u043c\u043e\u0436\u0435\u0442\u0435 \u0440\u0430\u0437\u043c\u0435\u0441\u0442\u0438\u0442\u044c \u0441\u0432\u043e\u044e \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u044e \u043d\u0430 \u043f\u0435\u0440\u0432\u044b\u0445 \u043c\u0435\u0441\u0442\u0430\u0445 \u0432 \u0441\u043f\u0438\u0441\u043a\u0435 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0439.\n\n'
      '\u0420\u0430\u0437\u043c\u0435\u0449\u0435\u043d\u0438\u0435 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0439 \u043d\u0435 \u043f\u0440\u043e\u0434\u043b\u0435\u0432\u0430\u0435\u0442\u0441\u044f \u0430\u0432\u0442\u043e\u043c\u0430\u0442\u0438\u0447\u0435\u0441\u043a\u0438 \u043f\u043e \u0438\u0441\u0442\u0435\u0447\u0435\u043d\u0438\u044e \u0441\u0440\u043e\u043a\u0430 \u0440\u0430\u0437\u043c\u0435\u0449\u0435\u043d\u0438\u044f, \u0434\u043b\u044f \u0440\u0430\u0437\u043c\u0435\u0449\u0435\u043d\u0438\u044f \u0441 \u0430\u0432\u0442\u043e\u043f\u0440\u043e\u0434\u043b\u0435\u043d\u0438\u0435\u043c \u043d\u0435\u043e\u0431\u0445\u043e\u0434\u0438\u043c\u043e \u0437\u0430\u0440\u0430\u043d\u0435\u0435 \u0441\u043e\u0432\u0435\u0440\u0448\u0438\u0442\u044c \u043f\u0440\u0435\u0434\u043e\u043f\u043b\u0430\u0442\u0443.\n\n'
      '\u041a\u0430\u043a \u0438\u0437\u043c\u0435\u043d\u0438\u0442\u044c \u0434\u0430\u043d\u043d\u044b\u0435 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438?\n\n'
      '\u0415\u0441\u043b\u0438 \u0432\u044b \u0437\u0430\u0440\u0435\u0433\u0438\u0441\u0442\u0440\u0438\u0440\u043e\u0432\u0430\u043d\u044b, \u0442\u043e \u043c\u043e\u0436\u0435\u0442\u0435 \u0441\u0430\u043c\u0438 \u0440\u0435\u0434\u0430\u043a\u0442\u0438\u0440\u043e\u0432\u0430\u0442\u044c \u0441\u0432\u043e\u0438 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438 \u0432 \u0440\u0430\u0437\u0434\u0435\u043b\u0435 \u041c\u043e\u0438 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438. \u0418\u043d\u0430\u0447\u0435 \u0447\u0442\u043e \u0431\u044b \u0438\u0437\u043c\u0435\u043d\u0438\u0442\u044c \u0434\u0430\u043d\u043d\u044b\u0435 \u043e \u0441\u0432\u043e\u0439 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438 \u043d\u0435\u043e\u0431\u0445\u043e\u0434\u0438\u043c\u043e \u0441\u0432\u044f\u0437\u0430\u0442\u044c\u0441\u044f \u0441 \u043d\u0430\u043c\u0438 \u0447\u0435\u0440\u0435\u0437 \u043d\u0430\u0448\u0435\u0433\u043e \u0430\u0434\u043c\u0438\u043d\u0438\u0441\u0442\u0440\u0430\u0442\u043e\u0440\u0430 \u0432 \u0438\u043d\u0441\u0442\u0430\u0433\u0440\u0430\u043c -\nhttps://www.instagram.com/vaytoday?igsh=MTA4MGsyMGxja2JsMw==\n\n'
      '\u0412\u0430\u0436\u043d\u043e, \u0447\u0442\u043e \u0431\u044b \u0432\u044b \u043f\u0438\u0441\u0430\u043b\u0438 \u0441 \u0430\u043a\u043a\u0430\u0443\u043d\u0442\u0430 \u0432\u0430\u0448\u0435\u0439 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438, \u0438\u043d\u0430\u0447\u0435 \u0432\u0430\u0448 \u0437\u0430\u043f\u0440\u043e\u0441 \u043d\u0435 \u0431\u0443\u0434\u0435\u0442 \u043e\u0431\u0440\u0430\u0431\u043e\u0442\u0430\u043d.',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.32,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ContactsContent extends StatelessWidget {
  const _ContactsContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SelectableText(
        'Instagram:\nwww.instagram.com/vaytoday\n\n'
        'Email:\nvaytoday@mail.ru\n\n'
        'Whatsapp/Telegram:\n8(962)669-66-69',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
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
        '\u0423\u0434\u0430\u043b\u0438\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442?',
        style: TextStyle(
          color: AppColors.authText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        hasCompanies
            ? '\u0412\u0441\u0435 \u0432\u0430\u0448\u0438 \u043a\u043e\u043c\u043f\u0430\u043d\u0438\u0438 \u0443\u0434\u0430\u043b\u044f\u0442\u0441\u044f \u0432\u043c\u0435\u0441\u0442\u0435 \u0441\u043e \u0432\u0441\u0435\u043c \u0430\u0441\u0441\u043e\u0440\u0442\u0438\u043c\u0435\u043d\u0442\u043e\u043c, \u043e\u0442\u0437\u044b\u0432\u0430\u043c\u0438 \u0438 \u0440\u0435\u0439\u0442\u0438\u043d\u0433\u043e\u043c. \u0412\u044b \u0443\u0432\u0435\u0440\u0435\u043d\u044b, \u0447\u0442\u043e \u0445\u043e\u0442\u0438\u0442\u0435 \u0443\u0434\u0430\u043b\u0438\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442?'
            : '\u0412\u044b \u0443\u0432\u0435\u0440\u0435\u043d\u044b, \u0447\u0442\u043e \u0445\u043e\u0442\u0438\u0442\u0435 \u0443\u0434\u0430\u043b\u0438\u0442\u044c \u0430\u043a\u043a\u0430\u0443\u043d\u0442? \u042d\u0442\u043e \u0434\u0435\u0439\u0441\u0442\u0432\u0438\u0435 \u043d\u0435\u043b\u044c\u0437\u044f \u043e\u0442\u043c\u0435\u043d\u0438\u0442\u044c.',
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
            _cancelTitle,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text(
            _deleteTitle,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
