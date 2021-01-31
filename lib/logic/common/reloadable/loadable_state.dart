part of 'reloadable_cubit.dart';

enum DataSubmissionState {
	notSubmitted, submissionInProgress, submissionSuccess, submissionFailure
}

abstract class LoadableState extends Equatable {
	@override
	List<Object> get props => [];
}

class DataLoadInitial extends LoadableState {}
class DataLoadInProgress extends LoadableState {}
abstract class DataLoadSuccess extends LoadableState {}
class DataLoadFailure extends LoadableState {}

class SubmittableDataLoadSuccess extends DataLoadSuccess {
  final DataSubmissionState submissionState;

  bool get submissionInProgress => submissionState == DataSubmissionState.submissionInProgress;
  bool get submitted => submissionState == DataSubmissionState.submissionInProgress;

  SubmittableDataLoadSuccess([DataSubmissionState submissionState]) :
        submissionState = submissionState ?? DataSubmissionState.notSubmitted;

  @override
  List<Object> get props => [submissionState];
}
