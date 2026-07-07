import 'package:equatable/equatable.dart';

sealed class AuthStatusState extends Equatable {
  const AuthStatusState();

  @override
  List<Object?> get props => [];
}

class AuthStatusInitial extends AuthStatusState {
  const AuthStatusInitial();
}

class AuthStatusChecking extends AuthStatusState {
  const AuthStatusChecking();
}

class AuthStatusAuthorized extends AuthStatusState {
  const AuthStatusAuthorized();
}

class AuthStatusUnauthorized extends AuthStatusState {
  const AuthStatusUnauthorized();
}
