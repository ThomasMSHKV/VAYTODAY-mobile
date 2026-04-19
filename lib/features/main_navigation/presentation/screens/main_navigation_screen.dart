import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../features/categories/presentation/screens/categories_screen.dart';
import '../../../../features/my_companies/presentation/screens/my_companies_screen.dart';
import '../cubit/navigation_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../cubit/navigation_state.dart';  // ← Добавь эту строку
import '../../../../features/profile/presentation/screens/profile_screens.dart';




class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    MyCompaniesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            return IndexedStack(
              index: state.selectedItem.index,
              children: _screens,
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}