import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class AuthInputField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final bool showEye;

  const AuthInputField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.showEye = false,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          Icon(widget.icon, color: AppColors.authGold, size: 26),

          const SizedBox(width: 2),

          Expanded(
            child: TextField(
              obscureText: _isObscured,
              cursorColor: AppColors.authGold,
              style: const TextStyle(
                color: AppColors.authText,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              decoration:
                  const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ).copyWith(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.authHint,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
            ),
          ),

          if (widget.showEye)
            GestureDetector(
              onTap: _togglePasswordVisibility,
              child: Icon(
                _isObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.authGold,
                size: 24,
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
