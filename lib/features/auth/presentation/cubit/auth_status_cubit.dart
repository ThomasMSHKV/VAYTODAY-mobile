import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:VayToday/features/auth/data/auth_session_storage.dart';
import 'package:VayToday/features/auth/presentation/cubit/auth_status_state.dart';

class AuthStatusCubit extends Cubit<AuthStatusState> {
  final AuthSessionStorage _sessionStorage;

  AuthStatusCubit(this._sessionStorage) : super(const AuthStatusInitial());

  Future<void> checkAuthorization() async {
    emit(const AuthStatusChecking());

    final isAuthorized = await _sessionStorage.isAuthorized();

    if (isAuthorized) {
      emit(const AuthStatusAuthorized());
      return;
    }

    emit(const AuthStatusUnauthorized());
  }
}
