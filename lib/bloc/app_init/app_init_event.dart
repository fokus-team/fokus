import 'package:equatable/equatable.dart';

abstract class AppInitEvent extends Equatable {
	const AppInitEvent();

	@override
	List<Object> get props => [];
}

class AppInitStartedEvent extends AppInitEvent {}

class AppInitCompletedEvent extends AppInitEvent {}

class AppInitFailedEvent extends AppInitEvent {
	final Object error;

	AppInitFailedEvent(this.error);

	@override
	List<Object> get props => [error];
}
