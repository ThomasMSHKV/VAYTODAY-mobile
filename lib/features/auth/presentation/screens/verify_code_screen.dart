import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_background.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String? password;
  final String? resetPassword;
  final VoidCallback? onVerified;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    this.password,
    this.resetPassword,
    this.onVerified,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _codeLength = 6;
  static const int _resendCooldownSeconds = 30;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  final _authRepository = AuthRepository();
  final _sessionStorage = AuthSessionStorage();

  Timer? _resendTimer;
  bool _isLoading = false;
  bool _isResending = false;
  int _resendSecondsLeft = _resendCooldownSeconds;

  bool get _isPasswordReset => widget.resetPassword != null;

  bool get _canResendCode {
    return _resendSecondsLeft == 0 && !_isResending && !_isLoading;
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  @override
  void initState() {
    super.initState();
    _startResendCooldown(notify: false);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length > 1) {
      final sanitized = value.replaceAll(RegExp(r'\D'), '');
      if (sanitized.length == _codeLength) {
        for (var i = 0; i < _codeLength; i++) {
          _controllers[i].text = sanitized[i];
        }
        FocusScope.of(context).unfocus();
        setState(() {});
        return;
      }

      _controllers[index].text = sanitized.isEmpty
          ? ''
          : sanitized.substring(sanitized.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index].text.length),
      );
    }

    if (_controllers[index].text.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_code.length == _codeLength) {
      FocusScope.of(context).unfocus();
    }

    setState(() {});
  }

  void _onBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _startResendCooldown({bool notify = true}) {
    _resendTimer?.cancel();

    void updateSecondsLeft() {
      _resendSecondsLeft = _resendCooldownSeconds;
    }

    if (notify) {
      setState(updateSecondsLeft);
    } else {
      updateSecondsLeft();
    }

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
        return;
      }

      setState(() => _resendSecondsLeft--);
    });
  }

  Future<void> _resendCode() async {
    if (!_canResendCode) return;

    setState(() => _isResending = true);

    try {
      if (_isPasswordReset) {
        await _authRepository.sendPasswordResetCode(widget.email);
      } else {
        await _authRepository.resendVerificationCode(widget.email);
      }

      if (!mounted) return;

      _startResendCooldown();
      _showMessage('Код отправлен повторно');
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Не удалось отправить код повторно');
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _confirmCode() async {
    if (_code.length != _codeLength || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_isPasswordReset) {
        await _authRepository.resetPassword(
          email: widget.email,
          code: _code,
          password: widget.resetPassword!,
        );
      } else {
        await _verifyRegistrationCode();
      }

      if (!mounted) return;

      if (!_isPasswordReset) {
        widget.onVerified?.call();
      }

      _showMessage(_isPasswordReset ? 'Пароль изменён' : 'Почта подтверждена');
      Navigator.of(context).pop(true);
    } on AuthApiException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        _isPasswordReset ? 'Не удалось изменить пароль' : 'Неверный код',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyRegistrationCode() async {
    await _authRepository.verifyEmail(
      email: widget.email,
      verificationCode: _code,
    );

    final password = widget.password;
    if (password == null || password.isEmpty) {
      await _sessionStorage.clear();
      throw const AuthApiException(
        'Почта подтверждена. Войдите в аккаунт заново.',
      );
    }

    final tokens = await _authRepository.login(
      email: widget.email,
      password: password,
    );
    await _sessionStorage.saveAuthorizedUser(widget.email, tokens: tokens);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = _code.length == _codeLength && !_isLoading;

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
                  const SizedBox(height: 122),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: Column(
                      children: [
                        Text(
                          _isPasswordReset ? 'Смена пароля' : 'Подтверждение',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.authText,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isPasswordReset
                              ? 'Введите 6-значный код, который мы отправили на вашу почту'
                              : 'Введите 6-значный код подтверждения, который мы отправили на вашу почту',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.authSubtitle,
                            fontSize: 20,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.authText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_codeLength, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: _CodeUnderlineField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) => _onCodeChanged(value, index),
                          onBackspace: (value) => _onBackspace(value, index),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 34),
                  _ResendCodeButton(
                    secondsLeft: _resendSecondsLeft,
                    isLoading: _isResending,
                    onTap: _canResendCode ? _resendCode : null,
                  ),
                  const SizedBox(height: 42),
                  GestureDetector(
                    onTap: isButtonEnabled ? _confirmCode : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isButtonEnabled ? 1 : 0.45,
                      child: Container(
                        width: 190,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.authBlack,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          _isLoading ? 'проверка' : 'подтвердить',
                          style: const TextStyle(
                            color: AppColors.authGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CodeUnderlineField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onBackspace;

  const _CodeUnderlineField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 52,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            onBackspace(controller.text);
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AppColors.authGold,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.authBlack,
            fontSize: 24,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
          strutStyle: const StrutStyle(height: 1, forceStrutHeight: true),
          decoration: const InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.only(bottom: 8),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.authBlack, width: 2.4),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.authBlack, width: 2.4),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.authGold, width: 3),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ResendCodeButton extends StatelessWidget {
  final int secondsLeft;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ResendCodeButton({
    required this.secondsLeft,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final text = isLoading
        ? 'Отправляем...'
        : isEnabled
        ? 'Отправить код заново'
        : 'Отправить код заново через $secondsLeft с';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isEnabled ? 1 : 0.58,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.authText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
