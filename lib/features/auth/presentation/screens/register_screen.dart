import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_background.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_switch_button.dart';
import 'package:VayToday/features/other/presentation/screens/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onAuthorized;

  const RegisterScreen({super.key, this.onAuthorized});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isPrivacyAccepted = false;
  bool _isPersonalDataAccepted = false;
  bool _isLoading = false;

  bool get _canSubmit {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        _isPrivacyAccepted &&
        _isPersonalDataAccepted &&
        !_isLoading;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_canSubmit) return;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароли не совпадают')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.register(email: email, password: password);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyCodeScreen(
            email: email,
            onVerified: widget.onAuthorized,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось зарегистрироваться')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _refreshSubmitState(String _) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  const SizedBox(height: 110),
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'РЕГИСТРАЦИЯ',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Создайте свой аккаунт',
                    style: TextStyle(
                      color: AppColors.authSubtitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 290,
                        margin: const EdgeInsets.only(right: 62),
                        padding: const EdgeInsets.fromLTRB(10, 34, 10, 20),
                        decoration: BoxDecoration(
                          color: AppColors.authCard,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(42),
                            bottomRight: Radius.circular(42),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            AuthInputField(
                              controller: _emailController,
                              hintText: 'mail',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: _refreshSubmitState,
                            ),
                            const SizedBox(height: 28),
                            AuthInputField(
                              controller: _passwordController,
                              hintText: 'password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              showEye: true,
                              onChanged: _refreshSubmitState,
                            ),
                            const SizedBox(height: 28),
                            AuthInputField(
                              controller: _confirmPasswordController,
                              hintText: 'confirm password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              showEye: true,
                              onChanged: _refreshSubmitState,
                            ),
                          ],
                        ),
                      ),
                      AuthSubmitButton(
                        icon: _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.check_rounded,
                        isEnabled: _canSubmit,
                        onTap: _register,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        _AuthAgreementCheckbox(
                          value: _isPrivacyAccepted,
                          text: '',
                          hasPrivacyLink: true,
                          onChanged: (value) {
                            setState(() {
                              _isPrivacyAccepted = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _AuthAgreementCheckbox(
                          value: _isPersonalDataAccepted,
                          text: 'Я согласен на обработку персональных данных',
                          onChanged: (value) {
                            setState(() {
                              _isPersonalDataAccepted = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 42),
                  AuthSwitchButton(
                    title: 'ВХОД',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AuthAgreementCheckbox extends StatelessWidget {
  final bool value;
  final String text;
  final bool hasPrivacyLink;
  final ValueChanged<bool> onChanged;

  const _AuthAgreementCheckbox({
    required this.value,
    required this.text,
    required this.onChanged,
    this.hasPrivacyLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.authBlack : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? AppColors.authBlack : AppColors.authGold,
                width: 1.6,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check_rounded,
                    color: AppColors.authGold,
                    size: 17,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: hasPrivacyLink
                ? Wrap(
                    children: [
                      const Text(
                        'Я согласен с ',
                        style: TextStyle(
                          color: AppColors.authSubtitle,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'политикой конфиденциальности',
                          style: TextStyle(
                            color: AppColors.authGold,
                            fontSize: 13,
                            height: 1.2,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.authGold,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.authSubtitle,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
