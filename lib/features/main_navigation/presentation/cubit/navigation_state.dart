import 'package:equatable/equatable.dart';
import '../../domain/entities/nav_item.dart';


class NavigationState extends Equatable {
  final NavItem selectedItem;

  const NavigationState({required this.selectedItem});

  factory NavigationState.initial() {
    return const NavigationState(selectedItem: NavItem.services);
  }

  NavigationState copyWith({NavItem? selectedItem}) {
    return NavigationState(
      selectedItem: selectedItem ?? this.selectedItem,
    );
  }

  @override
  List<Object> get props => [selectedItem];
}