import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 0, 0),
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Поиск',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blueGrey.shade400,
            size: 28,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
