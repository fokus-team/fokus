import 'package:equatable/equatable.dart';

abstract class AppInitState extends Equatable {
	const AppInitState();

	@override
	List<Object> get props => [];
}

class AppInitInProgress extends AppInitState {}

class AppInitSuccess extends AppInitState {}

class AppInitFailure extends AppInitState {
	final Object error;

	AppInitFailure(this.error);

	@override
  List<Object> get props => [error];
}
