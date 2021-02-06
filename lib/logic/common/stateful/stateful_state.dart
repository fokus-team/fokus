part of 'stateful_cubit.dart';

enum DataSubmissionState {
	notSubmitted, submissionInProgress, submissionSuccess, submissionFailure
}

enum DataLoadingState {
	notLoaded, loadingInProgress, loadSuccess, loadFailure
}

class StatefulState extends Equatable {
	final DataLoadingState loadingState;
	final DataSubmissionState submissionState;

	bool get loadingInProgress => loadingState == DataLoadingState.loadingInProgress;
	bool get loaded => loadingState == DataLoadingState.loadSuccess;
	bool get isNotSubmitted => submissionState == DataSubmissionState.notSubmitted;
	bool get submissionInProgress => submissionState == DataSubmissionState.submissionInProgress;
	bool get submitted => submissionState == DataSubmissionState.submissionSuccess;

	StatefulState({this.loadingState, this.submissionState});
	StatefulState.notLoaded([DataLoadingState loadingState]) : this(loadingState: loadingState ?? DataLoadingState.notLoaded, submissionState: DataSubmissionState.notSubmitted);
	StatefulState.loaded([DataSubmissionState submissionState]) : this(loadingState: DataLoadingState.loadSuccess, submissionState: submissionState ?? DataSubmissionState.notSubmitted);

	StatefulState withSubmitState(DataSubmissionState submissionState) => StatefulState.loaded(submissionState);
	StatefulState submit() => withSubmitState(DataSubmissionState.submissionInProgress);
	StatefulState notSubmitted() => withSubmitState(DataSubmissionState.notSubmitted);
	StatefulState submissionSuccess() => withSubmitState(DataSubmissionState.submissionSuccess);

	@override
	List<Object> get props => [loadingState, submissionState];
}
