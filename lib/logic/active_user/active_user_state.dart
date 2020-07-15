part of 'active_user_cubit.dart';

abstract class ActiveUserState extends Equatable {
  const ActiveUserState();
}

class NoActiveUser extends ActiveUserState {
	@override
	List<Object> get props => [];
}

class ActiveUserPresent extends ActiveUserState {
	final UserRole role;
	final String name;

	ActiveUserPresent(this.name, this.role);

  @override
	List<Object> get props => [name, role];
}
