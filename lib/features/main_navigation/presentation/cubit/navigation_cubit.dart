import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/nav_item.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState.initial());

  void changeTab(NavItem item) {
    emit(state.copyWith(selectedItem: item));
  }
}