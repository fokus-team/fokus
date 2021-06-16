part of 'task_completion_cubit.dart';

enum TaskCompletionStateType {
	inProgress, inBreak, finished, discarded
}

class TaskCompletionState extends StatefulState {
	final UITaskInstance? uiTask;
	final UIPlanInstance uiPlan;
	final TaskCompletionStateType? current;

	TaskCompletionState({this.uiTask, required this.uiPlan, this.current, DataLoadingState? loadingState, DataSubmissionState? submissionState}) :
				super(loadingState: loadingState, submissionState: submissionState);
	TaskCompletionState.inProgress({this.uiTask, required this.uiPlan, DataSubmissionState? submissionState}) :
				this.current = TaskCompletionStateType.inProgress, super.loaded(submissionState);
	TaskCompletionState.inBreak({this.uiTask, required this.uiPlan, DataSubmissionState? submissionState}) :
				this.current = TaskCompletionStateType.inBreak, super.loaded(submissionState);
	TaskCompletionState.finished({this.uiTask, required this.uiPlan, DataSubmissionState? submissionState}) :
				this.current = TaskCompletionStateType.finished, super.loaded(submissionState);
	TaskCompletionState.discarded({this.uiTask, required this.uiPlan, DataSubmissionState? submissionState}) :
				this.current = TaskCompletionStateType.discarded, super.loaded(submissionState);

	TaskCompletionState copyWith({UITaskInstance? taskInstance, UIPlanInstance? planInstance,
			TaskCompletionStateType? current, DataLoadingState? loadingState, DataSubmissionState? submissionState}) {
		return TaskCompletionState(
			uiTask: taskInstance ?? this.uiTask,
			uiPlan: planInstance ?? this.uiPlan,
			current: current ?? this.current,
			loadingState: loadingState ?? this.loadingState,
			submissionState: submissionState ?? this.submissionState
		);
	}

	TaskCompletionState copyWithSubmitted({UITaskInstance? taskInstance, UIPlanInstance? planInstance, TaskCompletionStateType? current}) =>
			copyWith(taskInstance: taskInstance, planInstance: planInstance, current: current, submissionState: DataSubmissionState.submissionSuccess);

	@override
  StatefulState withLoadState(DataLoadingState loadingState) => copyWith(loadingState: loadingState);

  @override
  StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

  @override
  List<Object?> get props => super.props..addAll([this.uiTask, this.uiPlan, this.current]);
}
