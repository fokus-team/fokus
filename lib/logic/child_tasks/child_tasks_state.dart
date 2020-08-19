part of 'child_tasks_cubit.dart';

abstract class ChildTasksState extends Equatable {
	const ChildTasksState();

	@override
	List<Object> get props => [];
}

class ChildTasksInitial extends ChildTasksState {}

class ChildTasksLoadInProgress extends ChildTasksState {}

class ChildTasksLoadSuccess extends ChildTasksState {
	final List<UITaskInstance> tasks;

	ChildTasksLoadSuccess(this.tasks);

	@override
	List<Object> get props => [tasks];

	@override
	String toString() {
		return 'ChildTasksLoadSuccess{tasks: $tasks}';
	}
}
