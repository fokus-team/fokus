part of 'active_user_cubit.dart';

abstract class ActiveUserState extends Equatable {
  const ActiveUserState();

  @override
  List<Object> get props => [];
}

class NoActiveUser extends ActiveUserState {}

class ActiveUserPresent extends ActiveUserState {
	final UIUser user;

	ActiveUserPresent(this.user);

  @override
	List<Object> get props => [user];
}
