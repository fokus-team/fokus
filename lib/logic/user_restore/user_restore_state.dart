import 'package:equatable/equatable.dart';

import 'package:fokus/model/db/user/user_role.dart';

abstract class UserRestoreState extends Equatable {
  const UserRestoreState();

  @override
  List<Object> get props => [];
}

class UserRestoreInitialState extends UserRestoreState {}

class UserRestoreSuccess extends UserRestoreState {
	final UserRole userRole;

	UserRestoreSuccess(this.userRole);

	@override
	List<Object> get props => [userRole];
}

class UserRestoreFailure extends UserRestoreState {}
