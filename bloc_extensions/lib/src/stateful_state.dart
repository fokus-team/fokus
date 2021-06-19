import 'package:equatable/equatable.dart';

enum DataSubmissionState {
	notSubmitted, submissionInProgress, submissionSuccess, submissionFailure
}

enum DataLoadingState {
	notLoaded, loadingInProgress, loadSuccess, loadFailure
}

class StatefulState<CubitData> extends Equatable {
	final CubitData? data;
	final DataLoadingState loadingState;
	final DataSubmissionState submissionState;

	bool get notLoaded => loadingState == DataLoadingState.notLoaded;
	bool get beingLoaded => loadingState == DataLoadingState.loadingInProgress;
	bool get loaded => loadingState == DataLoadingState.loadSuccess;
	bool get loadFailed => loadingState == DataLoadingState.loadFailure;
	bool get notSubmitted => submissionState == DataSubmissionState.notSubmitted;
	bool get beingSubmitted => submissionState == DataSubmissionState.submissionInProgress;
	bool get submitted => submissionState == DataSubmissionState.submissionSuccess;

	StatefulState({this.data, this.loadingState = DataLoadingState.notLoaded, this.submissionState = DataSubmissionState.notSubmitted});

	StatefulState<CubitData> copyWith({CubitData? data, DataLoadingState? loadingState, DataSubmissionState? submissionState}) {
		return StatefulState(
			data: data ?? this.data,
			loadingState: loadingState ?? this.loadingState,
			submissionState: submissionState ?? this.submissionState,
		);
	}

	@override
	List<Object?> get props => [data, loadingState, submissionState];
}
