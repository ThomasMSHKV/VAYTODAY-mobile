import 'package:flutter/material.dart';

class CompaniesSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const CompaniesSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Поиск',

          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade500,
            size: 28,
          ),

          filled: true,
          fillColor: Colors.white,

          /// 👇 ВОТ ГЛАВНОЕ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24), // 👈 сильное скругление
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
