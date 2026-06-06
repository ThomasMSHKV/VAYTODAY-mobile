import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VayToday/core/theme/app_colors.dart';
import 'package:VayToday/features/auth/data/auth_repository.dart';
import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/presentation/widgets/auth_background.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String? resetPassword;
  final VoidCallback? onVerified;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    this.resetPassword,
    this.onVerified,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const int _codeLength = 6;

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
  bool _isLoading = false;

  bool get _isPasswordReset => widget.resetPassword != null;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  String get _code => _controllers.map((e) => e.text).join();

  void _onCodeChanged(String value, int index) {
    if (value.length > 1) {
      _controllers[index].text = value.substring(value.length - 1);
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );
    }

    if (value.isNotEmpty && index < _codeLength - 1) {
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
        await _authRepository.verifyEmail(
          email: widget.email,
          verificationCode: _code,
        );
        await _sessionStorage.saveAuthorizedUser(widget.email);
      }

      if (!mounted) return;

      if (!_isPasswordReset) {
        widget.onVerified?.call();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPasswordReset ? 'Пароль изменен' : 'Почта подтверждена',
          ),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный код')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                  const SizedBox(height: 150),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 46),
                    child: Text(
                      'Введите код аутентификации который мы отправили на вашу почту',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.authSubtitle,
                        fontSize: 22,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 90),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_codeLength, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _CodeCircleField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) => _onCodeChanged(value, index),
                          onBackspace: (value) => _onBackspace(value, index),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 80),
                  GestureDetector(
                    onTap: isButtonEnabled ? _confirmCode : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isButtonEnabled ? 1 : 0.45,
                      child: Container(
                        width: 250,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.authBlack,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Text(
                          _isLoading ? 'проверка' : 'подтвердить',
                          style: const TextStyle(
                            color: AppColors.authGold,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
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

class _CodeCircleField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onBackspace;

  const _CodeCircleField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
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
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AppColors.authGold,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.authGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
          decoration: const InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.authBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
