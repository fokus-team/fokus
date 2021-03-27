// @dart = 2.10
part of 'task_completion_cubit.dart';

enum TaskCompletionStateType {
	inProgress, inBreak, finished, discarded
}

class TaskCompletionState extends StatefulState {
	final UITaskInstance taskInstance;
	final UIPlanInstance planInstance;
	final TaskCompletionStateType current;

	TaskCompletionState({this.taskInstance, this.planInstance, this.current, DataLoadingState loadingState, DataSubmissionState submissionState}) :
				super(loadingState: loadingState, submissionState: submissionState);
	TaskCompletionState.inProgress({this.taskInstance, this.planInstance, DataSubmissionState submissionState}) :
				this.current = TaskCompletionStateType.inProgress, super.loaded(submissionState);
	TaskCompletionState.inBreak({this.taskInstance, this.planInstance, DataSubmissionState submissionState}) :
				this.current = TaskCompletionStateType.inBreak, super.loaded(submissionState);
	TaskCompletionState.finished({this.taskInstance, this.planInstance, DataSubmissionState submissionState}) :
				this.current = TaskCompletionStateType.finished, super.loaded(submissionState);
	TaskCompletionState.discarded({this.taskInstance, this.planInstance, DataSubmissionState submissionState}) :
				this.current = TaskCompletionStateType.discarded, super.loaded(submissionState);

	TaskCompletionState copyWith({UITaskInstance taskInstance, UIPlanInstance planInstance,
			TaskCompletionStateType current, DataLoadingState loadingState, DataSubmissionState submissionState}) {
		return TaskCompletionState(
			taskInstance: taskInstance ?? this.taskInstance,
			planInstance: planInstance ?? this.planInstance,
			current: current ?? this.current,
			loadingState: loadingState ?? this.loadingState,
			submissionState: submissionState ?? this.submissionState
		);
	}

	TaskCompletionState copyWithSubmitted({UITaskInstance taskInstance, UIPlanInstance planInstance, TaskCompletionStateType current}) =>
			copyWith(taskInstance: taskInstance, planInstance: planInstance, current: current, submissionState: DataSubmissionState.submissionSuccess);

	@override
  StatefulState withLoadState(DataLoadingState loadingState) => copyWith(loadingState: loadingState);

  @override
  StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

  @override
  List<Object> get props => super.props..addAll([this.taskInstance, this.planInstance, this.current]);
}
