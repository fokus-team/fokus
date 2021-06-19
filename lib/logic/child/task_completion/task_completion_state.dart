part of 'task_completion_cubit.dart';

enum TaskCompletionStateType {
	inProgress, inBreak, finished, discarded
}

class TaskCompletionData extends Equatable {
	final UITaskInstance? uiTask;
	final UIPlanInstance uiPlan;
	final TaskCompletionStateType? current;

	TaskCompletionData({this.uiTask, required this.uiPlan, this.current});

	TaskCompletionData.inProgress({this.uiTask, required this.uiPlan}) : current = TaskCompletionStateType.inProgress;
	TaskCompletionData.inBreak({this.uiTask, required this.uiPlan}) : current = TaskCompletionStateType.inBreak;
	TaskCompletionData.finished({this.uiTask, required this.uiPlan}) : current = TaskCompletionStateType.finished;
	TaskCompletionData.discarded({this.uiTask, required this.uiPlan}) : current = TaskCompletionStateType.discarded;

	TaskCompletionData copyWith({UITaskInstance? taskInstance, UIPlanInstance? planInstance, TaskCompletionStateType? current}) {
		return TaskCompletionData(
			uiTask: taskInstance ?? uiTask,
			uiPlan: planInstance ?? uiPlan,
			current: current ?? this.current,
		);
	}

  @override
  List<Object?> get props => [uiTask, uiPlan, current];
}
