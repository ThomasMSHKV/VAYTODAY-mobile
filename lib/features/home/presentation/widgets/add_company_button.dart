import 'package:flutter/material.dart';

class AddCompanyButton extends StatelessWidget {
  const AddCompanyButton({super.key});

  void _showUnauthorizedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Ошибка'),
          content: const Text('Вы еще не авторизированы'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Понятно'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showUnauthorizedDialog(context),
      child: Ink(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFFEAC86B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.add,
          size: 30,
          color: Color(0xFF45524A),
        ),
      ),
    );
  }
}