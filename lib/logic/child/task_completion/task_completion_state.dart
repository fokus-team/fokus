part of 'task_completion_cubit.dart';

enum TaskCompletionStateType {
	inProgress, inBreak, finished, discarded
}

abstract class TaskCompletionState extends Equatable {
  const TaskCompletionState();
}

class TaskCompletionStateInitial extends TaskCompletionState {
	final UIPlanInstance planInstance;

  TaskCompletionStateInitial(this.planInstance);

	@override
  List<Object> get props => [planInstance];
}

class TaskCompletionStateLoaded extends TaskCompletionState {
	final UITaskInstance taskInstance;
	final UIPlanInstance planInstance;
	final TaskCompletionStateType current;
	final bool isLoading;

	TaskCompletionStateLoaded({this.taskInstance, this.planInstance, this.current, this.isLoading = false});
	TaskCompletionStateLoaded.inProgress({this.taskInstance, this.planInstance, this.isLoading = false}) : this.current = TaskCompletionStateType.inProgress;
	TaskCompletionStateLoaded.inBreak({this.taskInstance, this.planInstance, this.isLoading = false}) : this.current = TaskCompletionStateType.inBreak;
	TaskCompletionStateLoaded.finished({this.taskInstance, this.planInstance, this.isLoading = false}) : this.current = TaskCompletionStateType.finished;
	TaskCompletionStateLoaded.discarded({this.taskInstance, this.planInstance, this.isLoading = false}) : this.current = TaskCompletionStateType.discarded;

	TaskCompletionStateLoaded copyWith({UITaskInstance taskInstance, UIPlanInstance planInstance, TaskCompletionStateType current, bool isLoading = false}) {
		return TaskCompletionStateLoaded(
			taskInstance: taskInstance ?? this.taskInstance,
			planInstance: planInstance ?? this.planInstance,
			current: current ?? this.current,
			isLoading: isLoading ?? this.isLoading
		);
	}

  @override
  List<Object> get props => [this.taskInstance, this.planInstance, this.current, this.isLoading];
}
