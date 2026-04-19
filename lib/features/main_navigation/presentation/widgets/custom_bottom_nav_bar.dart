import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/nav_item.dart';
import '../cubit/navigation_cubit.dart';
import '../cubit/navigation_state.dart'; 


class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Container(
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.surface,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: NavItem.values.map((item) {
              final isActive = state.selectedItem == item;
              return _NavBarItem(
                item: item,
                isActive: isActive,
                onTap: () {
                  context.read<NavigationCubit>().changeTab(item);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Размер иконки: активная больше, неактивная меньше
    final iconSize = isActive ? 26.0 : 24.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: isActive ? 64 : 56,
        height: isActive ? 64 : 56,
        decoration: BoxDecoration(
          // Квадратный фон с округлёнными углами для активного элемента
          color: isActive 
              ? AppColors.navActiveBackground 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          color: isActive ? AppColors.navActiveIcon : AppColors.navInactiveIcon,
          size: iconSize,
        ),
      ),
    );
  }
}