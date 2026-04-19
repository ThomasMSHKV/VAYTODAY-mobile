import 'package:flutter/material.dart';

class MyCompaniesScreen extends StatelessWidget {
  const MyCompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои компании'),
      ),
      body: const Center(
        child: Text('Экран моих компаний'),
      ),
    );
  }
}