import 'package:equatable/equatable.dart';
import 'package:fokus/data/model/user/caregiver.dart';

abstract class AppInitState extends Equatable {
	const AppInitState();

	@override
	List<Object> get props => [];
}

class InitialAppInitState extends AppInitState {}

class AppInitInProgressState extends AppInitState {}

class AppInitSuccessState extends AppInitState {
	final Caregiver user;

	AppInitSuccessState(this.user);

	@override
	List<Object> get props => [user];
}

class AppInitFailureState extends AppInitState {
	final Object error;

	AppInitFailureState(this.error);

	@override
  List<Object> get props => [error];
}
