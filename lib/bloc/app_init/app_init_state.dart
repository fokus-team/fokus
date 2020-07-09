import 'package:equatable/equatable.dart';
import 'package:fokus/data/model/user/caregiver.dart';

abstract class AppInitState extends Equatable {
	const AppInitState();

	@override
	List<Object> get props => [];
}

class InitialAppInitState extends AppInitState {}

class AppInitInProgress extends AppInitState {}

class AppInitSuccess extends AppInitState {
	final Caregiver user;

	AppInitSuccess(this.user);

	@override
	List<Object> get props => [user];
}

class AppInitFailure extends AppInitState {
	final Object error;

	AppInitFailure(this.error);

	@override
  List<Object> get props => [error];
}
