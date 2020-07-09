import 'package:equatable/equatable.dart';

abstract class AppInitEvent extends Equatable {
	const AppInitEvent();

	@override
	List<Object> get props => [];
}

class AppInitStarted extends AppInitEvent {}

class AppInitCompleted extends AppInitEvent {}

class AppInitFailed extends AppInitEvent {
	final Object error;

	AppInitFailed(this.error);

	@override
	List<Object> get props => [error];
}
