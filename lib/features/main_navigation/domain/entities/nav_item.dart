import 'package:flutter/material.dart';

enum NavItem {
  services(0, Icons.home_outlined, Icons.home),
  categories(1, Icons.category_outlined, Icons.category),
  myCompanies(2, Icons.business_outlined, Icons.business),
  profile(3, Icons.person_outlined, Icons.person);

  final int navIndex;
  final IconData icon;
  final IconData activeIcon;

  const NavItem(this.navIndex, this.icon, this.activeIcon);
}