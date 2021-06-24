import 'dart:async';

import 'stateful_state.dart';

/// Performs the stateful operation [body] of [type]
Stream<StatefulState<Data>> execute<Data>({
  required StatefulState<Data> state,
  required OperationType type,
  required FutureOr<Data?> Function() body,
  Data? initialState,
}) async* {
  OperationState? filter(OperationState state, OperationType byType) =>
      byType == type ? state : null;
  yield state.copyWith(
    data: initialState,
    loadingState: filter(OperationState.inProgress, OperationType.loading),
    submissionState: filter(OperationState.inProgress, OperationType.submission),
  );
  try {
    yield state.copyWith(
      data: await body(),
      loadingState: filter(OperationState.success, OperationType.loading),
      submissionState: filter(OperationState.success, OperationType.submission),
    );
  } on Exception {
    yield state.copyWith(
      loadingState: filter(OperationState.failure, OperationType.loading),
      submissionState: filter(OperationState.failure, OperationType.submission),
    );
    rethrow;
  }
}
