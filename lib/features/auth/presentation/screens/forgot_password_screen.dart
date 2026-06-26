import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/presentation/screens/verify_code_screen.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_background.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_submit_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authRepository = AuthRepository();

  bool _isLoading = false;

  bool get _canSubmit {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        !_isLoading;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCodeAndOpenVerification() async {
    if (!_canSubmit) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage('Введите корректную почту');
      return;
    }

    if (password.length < 8) {
      _showMessage('Пароль должен быть не короче 8 символов');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authRepository.sendPasswordResetCode(email);

      if (!mounted) return;

      final isChanged = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              VerifyCodeScreen(email: email, resetPassword: password),
        ),
      );

      if (!mounted) return;

      if (isChanged == true) {
        Navigator.of(context).pop(true);
      }
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось отправить код');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _refreshSubmitState(String _) {
    setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                  const SizedBox(height: 96),
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'СБРОС',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Введите почту и новый пароль',
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
                              hintText: 'новый пароль',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              showEye: true,
                              onChanged: _refreshSubmitState,
                            ),
                            const SizedBox(height: 28),
                            AuthInputField(
                              controller: _confirmPasswordController,
                              hintText: 'повторите пароль',
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
                            : Icons.arrow_forward_rounded,
                        isEnabled: _canSubmit,
                        onTap: _sendCodeAndOpenVerification,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 42),
                    child: Text(
                      'Мы отправим 6-значный код на указанную почту',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.authSubtitle,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
