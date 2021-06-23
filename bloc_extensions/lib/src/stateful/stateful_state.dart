import 'package:equatable/equatable.dart';

/// States a loading or submission operation could be in
enum OperationState {
	/// Operation has not yet been started
  notStarted,
	/// Operation is currently ongoing
  inProgress,
	/// Operation finished successfully
  success,
	/// Operation was not finished due to an error
  failure,
}

/// State used by the stateful bloc extension
///
/// In addition to user provided [data] that would normally be the whole state
/// it tracks both [loadingState] and [submissionState] in a generalized way.
class StatefulState<Data> extends Equatable {
	/// User provided state data
  final Data? data;
  /// Current data loading state
  final OperationState loadingState;
  /// Current data submission state
  final OperationState submissionState;

  /// Returns if the data is not yet loaded
  bool get notLoaded => loadingState == OperationState.notStarted;
  /// Returns if the data is currently being loaded
  bool get beingLoaded => loadingState == OperationState.inProgress;
  /// Returns if the data was loaded successfully
  bool get loaded => loadingState == OperationState.success;
  /// Returns if the data was not loaded due a failure
  bool get loadFailed => loadingState == OperationState.failure;
  /// Returns if the data is not yet submitted
  bool get notSubmitted => submissionState == OperationState.notStarted;
  /// Returns if the data is currently being submitted
  bool get beingSubmitted => submissionState == OperationState.inProgress;
  /// Returns if the data was submitted successfully
  bool get submitted => submissionState == OperationState.success;
  /// Returns if the data was not submitted due a failure
  bool get submitFailed => submissionState == OperationState.failure;

  /// Creates an instance of Stateful State
  ///
  /// By default the [data] is not present - neither loaded nor submitted.
  StatefulState({
    this.data,
    this.loadingState = OperationState.notStarted,
    this.submissionState = OperationState.notStarted,
  });

  /// Standard state copying method
  StatefulState<Data> copyWith({
    Data? data,
    OperationState? loadingState,
    OperationState? submissionState,
  }) {
    return StatefulState(
      data: data ?? this.data,
      loadingState: loadingState ?? this.loadingState,
      submissionState: submissionState ?? this.submissionState,
    );
  }

  @override
  List<Object?> get props => [data, loadingState, submissionState];
}
