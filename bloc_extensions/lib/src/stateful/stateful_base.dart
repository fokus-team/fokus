import 'dart:async';

import 'stateful_state.dart';

/// Performs the stateful operation [body] of [type]
Stream<StatefulState<Data>> execute<Data>({
  required StatefulState<Data> state,
  required OperationType type,
  required FutureOr<Data?> Function() body,
  required void Function(Object, StackTrace) onError,
  Data? initialState,
}) async* {
  OperationState? set(OperationState state, OperationType byType) =>
      byType == type ? state : null;
  yield state.copyWith(
    data: initialState,
    loadingState: set(OperationState.inProgress, OperationType.loading),
    submissionState: set(OperationState.inProgress, OperationType.submission),
  );
  try {
    yield state.copyWith(
      data: await body(),
      loadingState: set(OperationState.success, OperationType.loading),
      submissionState: set(OperationState.success, OperationType.submission),
    );
    // ignore: avoid_catches_without_on_clauses
  } catch (error, stackTrace) {
    yield state.copyWith(
      loadingState: set(OperationState.failure, OperationType.loading),
      submissionState: set(OperationState.failure, OperationType.submission),
    );
    onError(error, stackTrace);
  }
}
