import 'dart:async';

import 'stateful_state.dart';

/// Result of a gracefully finished action
class Action<Data> {
  /// Action result status
  final ActionStatus status;

  /// User provided result data
  final Data? data;

  /// Indicates the action successfully finished
  Action.finish([this.data]) : status = ActionStatus.done;

  /// Indicates the action failed
  Action.fail([this.data]) : status = ActionStatus.failed;

  /// Indicates the action was canceled
  Action.cancel([this.data]) : status = ActionStatus.canceled;
}

/// Executes a stateful action
Stream<StatefulState<Data>> execute<Data>({
  required StatefulState<Data> state,
  required ActionType type,
  required FutureOr<Action<Data>?> Function() body,
  required void Function(Object, StackTrace) onError,
  Data? initialData,
}) async* {
  ActionStatus? set(ActionStatus state, ActionType byType) =>
      byType == type ? state : null;
  yield state = state.copyWith(
    data: initialData,
    loadingStatus: set(ActionStatus.ongoing, ActionType.loading),
    submissionStatus: set(ActionStatus.ongoing, ActionType.submission),
  );
  try {
    var action = await body();
    var status = action?.status ?? ActionStatus.done;
    yield state.copyWith(
      data: action?.data,
      loadingStatus: set(status, ActionType.loading),
      submissionStatus: set(status, ActionType.submission),
    );
    // ignore: avoid_catches_without_on_clauses
  } catch (error, stackTrace) {
    yield state.copyWith(
      loadingStatus: set(ActionStatus.failed, ActionType.loading),
      submissionStatus: set(ActionStatus.failed, ActionType.submission),
    );
    onError(error, stackTrace);
  }
}
