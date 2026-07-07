import 'package:flutter/material.dart';
import 'package:VayToday/core/theme/app_colors.dart';

class HomeSearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;

  const HomeSearchField({super.key, required this.onChanged, this.onTap});

  @override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: _controller,
        onTap: widget.onTap,
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        cursorColor: AppColors.authGold,
        decoration: InputDecoration(
          hintText: 'Поиск',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade400,
            size: 24,
          ),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(color: AppColors.authGold, width: 1.4),
          ),
        ),
      ),
    );
  }
}
