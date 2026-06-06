import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:VayToday/features/auth/presentation/screens/register_screen.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_background.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_switch_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onAuthorized;

  const LoginScreen({super.key, this.onAuthorized});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  final _sessionStorage = AuthSessionStorage();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final tokens = await _authRepository.login(
        email: email,
        password: password,
      );
      await _sessionStorage.saveAuthorizedUser(email, tokens: tokens);

      if (!mounted) return;

      widget.onAuthorized?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы авторизованы')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный mail или пароль')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                    'ВХОД',
                    style: TextStyle(
                      color: AppColors.authText,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Войдите в свой аккаунт',
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
                        height: 210,
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
                            ),
                            const SizedBox(height: 28),
                            AuthInputField(
                              controller: _passwordController,
                              hintText: 'password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: true,
                              showEye: true,
                            ),
                          ],
                        ),
                      ),
                      AuthSubmitButton(
                        top: 70,
                        icon: _isLoading
                            ? Icons.hourglass_empty_rounded
                            : Icons.check_rounded,
                        onTap: _login,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Забыли пароль ?',
                      style: TextStyle(
                        color: AppColors.authText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthSwitchButton(
                    title: 'РЕГИСТРАЦИЯ',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RegisterScreen(
                            onAuthorized: widget.onAuthorized,
                          ),
                        ),
                      );
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
