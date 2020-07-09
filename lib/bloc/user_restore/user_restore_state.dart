import 'package:equatable/equatable.dart';
import 'package:fokus/data/model/user/user.dart';

abstract class UserRestoreState extends Equatable {
  const UserRestoreState();

  @override
  List<Object> get props => [];
}

class UserRestoreInitialState extends UserRestoreState {}

class UserRestoreSuccess extends UserRestoreState {
	final User user;

	UserRestoreSuccess(this.user);

	@override
	List<Object> get props => [user];
}

class UserRestoreFailure extends UserRestoreState {}
