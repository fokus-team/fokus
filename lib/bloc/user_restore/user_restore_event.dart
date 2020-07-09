import 'package:equatable/equatable.dart';

abstract class UserRestoreEvent extends Equatable {
  const UserRestoreEvent();
}

class UserRestoreStarted extends UserRestoreEvent {
	@override
	List<Object> get props => [];
}
