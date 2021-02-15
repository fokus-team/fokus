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

	bool get isNotLoaded => loadingState == DataLoadingState.notLoaded;
	bool get loadingInProgress => loadingState == DataLoadingState.loadingInProgress;
	bool get loaded => loadingState == DataLoadingState.loadSuccess;
	bool get isNotSubmitted => submissionState == DataSubmissionState.notSubmitted;
	bool get submissionInProgress => submissionState == DataSubmissionState.submissionInProgress;
	bool get submitted => submissionState == DataSubmissionState.submissionSuccess;

	StatefulState({DataLoadingState loadingState, DataSubmissionState submissionState}) :
				loadingState = loadingState ?? DataLoadingState.notLoaded, submissionState = submissionState ?? DataSubmissionState.notSubmitted;
	StatefulState.notLoaded([DataLoadingState loadingState]) : this(loadingState: loadingState, submissionState: DataSubmissionState.notSubmitted);
	StatefulState.loaded([DataSubmissionState submissionState]) : this(loadingState: DataLoadingState.loadSuccess, submissionState: submissionState);

	StatefulState withLoadState(DataLoadingState loadingState) => StatefulState.notLoaded(loadingState);
	StatefulState notLoaded() => withLoadState(DataLoadingState.notLoaded);
	StatefulState loading() => withLoadState(DataLoadingState.loadingInProgress);

	StatefulState withSubmitState(DataSubmissionState submissionState) => StatefulState.loaded(submissionState);
	StatefulState submit() => withSubmitState(DataSubmissionState.submissionInProgress);
	StatefulState notSubmitted() => withSubmitState(DataSubmissionState.notSubmitted);
	StatefulState submissionSuccess() => withSubmitState(DataSubmissionState.submissionSuccess);

	@override
	List<Object> get props => [loadingState, submissionState];
}

class BaseFormState extends StatefulState {
	final AppFormType formType;

	BaseFormState({this.formType, DataLoadingState loadingState, DataSubmissionState submissionState}) :
				super(loadingState: loadingState, submissionState: submissionState);

	@override
	StatefulState withLoadState(DataLoadingState loadingState) => BaseFormState(formType: formType, loadingState: loadingState);

	@override
	List<Object> get props => super.props..addAll([formType]);
}
