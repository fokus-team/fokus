part of 'reloadable_cubit.dart';

enum DataSubmissionState {
	notSubmitted, submissionInProgress, submissionSuccess, submissionFailure
}

enum DataLoadingState {
	notLoaded, loadingInProgress, loadSuccess, loadFailure
}

class LoadableState extends Equatable {
	final DataLoadingState loadingState;
	final DataSubmissionState submissionState;

	bool get loadingInProgress => loadingState == DataLoadingState.loadingInProgress;
	bool get loaded => loadingState == DataLoadingState.loadSuccess;
	bool get isNotSubmitted => submissionState == DataSubmissionState.notSubmitted;
	bool get submissionInProgress => submissionState == DataSubmissionState.submissionInProgress;
	bool get submitted => submissionState == DataSubmissionState.submissionSuccess;

	LoadableState({this.loadingState, this.submissionState});
	LoadableState.notLoaded([DataLoadingState loadingState]) : this(loadingState: loadingState ?? DataLoadingState.notLoaded, submissionState: DataSubmissionState.notSubmitted);
	LoadableState.loaded([DataSubmissionState submissionState]) : this(loadingState: DataLoadingState.loadSuccess, submissionState: submissionState ?? DataSubmissionState.notSubmitted);

	LoadableState withSubmitState(DataSubmissionState submissionState) => LoadableState.loaded(submissionState);
	LoadableState submit() => withSubmitState(DataSubmissionState.submissionInProgress);
	LoadableState notSubmitted() => withSubmitState(DataSubmissionState.notSubmitted);
	LoadableState submissionSuccess() => withSubmitState(DataSubmissionState.submissionSuccess);

	@override
	List<Object> get props => [loadingState, submissionState];
}
