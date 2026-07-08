import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/categories/presentation/screens/categories_screen.dart';
import '../../../../features/home/presentation/screens/home_screen.dart';
import '../../../../features/my_companies/presentation/screens/my_companies_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screens.dart';
import '../../domain/entities/nav_item.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: Scaffold(
        body: BlocBuilder<NavigationCubit, NavigationState>(
          builder: (context, state) {
            return IndexedStack(
              index: state.selectedItem.index,
              children: [
                const HomeScreen(),
                const CategoriesScreen(),
                const MyCompaniesScreen(),
                ProfileScreen(
                  refreshToken: state.selectedItem == NavItem.profile
                      ? DateTime.now().microsecondsSinceEpoch
                      : 0,
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
