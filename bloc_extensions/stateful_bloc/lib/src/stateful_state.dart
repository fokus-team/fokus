import 'package:equatable/equatable.dart';

/// Possible states of a loading or submission actions
enum ActionStatus {
  /// Action has not yet been started
  initial,

  /// Action is currently ongoing
  ongoing,

  /// Action finished successfully
  done,

  /// Action was not finished due to an error
  failed,

  /// Action was canceled
  canceled,
}

/// Tracked action types
enum ActionType {
  /// Loading action
  loading,

  /// Submission action
  submission,
}

/// State used by the stateful bloc extension
///
/// {@template stateful_state}
/// It's designed to be a seamless, flexible extension
/// of a user provided [Data] state type by embedding it along
/// with two standardized statuses that track loading and submission.
/// {@endtemplate}
class StatefulState<Data> extends Equatable {
  /// User provided state data
  final Data? data;

  /// Current data loading state
  final ActionStatus loadingStatus;

  /// Current data submission state
  final ActionStatus submissionStatus;

  /// Returns if the data is not yet loaded
  bool get notLoaded => loadingStatus == ActionStatus.initial;

  /// Returns if the data is currently being loaded
  bool get beingLoaded => loadingStatus == ActionStatus.ongoing;

  /// Returns if the data was loaded successfully
  bool get loaded => loadingStatus == ActionStatus.done;

  /// Returns if the data was not loaded due a failure
  bool get loadFailed => loadingStatus == ActionStatus.failed;

  /// Returns if the data loading was canceled
  bool get loadCanceled => loadingStatus == ActionStatus.canceled;

  /// Returns if the data is not yet submitted
  bool get notSubmitted => submissionStatus == ActionStatus.initial;

  /// Returns if the data is currently being submitted
  bool get beingSubmitted => submissionStatus == ActionStatus.ongoing;

  /// Returns if the data was submitted successfully
  bool get submitted => submissionStatus == ActionStatus.done;

  /// Returns if the data was not submitted due a failure
  bool get submitFailed => submissionStatus == ActionStatus.failed;

  /// Returns if the data submission was canceled
  bool get submitCanceled => submissionStatus == ActionStatus.canceled;

  /// Creates an instance of Stateful State
  ///
  /// By default the [data] is not present - neither loaded nor submitted.
  StatefulState({
    this.data,
    this.loadingStatus = ActionStatus.initial,
    this.submissionStatus = ActionStatus.initial,
  });

  /// Standard state copying method
  StatefulState<Data> copyWith({
    Data? data,
    ActionStatus? loadingStatus,
    ActionStatus? submissionStatus,
  }) {
    return StatefulState(
      data: data ?? this.data,
      loadingStatus: loadingStatus ?? this.loadingStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  @override
  List<Object?> get props => [data, loadingStatus, submissionStatus];
}
