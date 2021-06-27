import 'package:bloc_extensions/bloc_extensions.dart';
import 'package:bloc_extensions/src/stateful/stateful_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'models.dart';

Future expectStates({
  required OperationType type,
  required Stream<StatefulState<Data>> stream,
  Data? initial,
  Data? loaded,
  bool fails = false,
}) async {
  final states = [
    OperationState.inProgress,
    fails ? OperationState.failure : OperationState.success,
  ];
  return expectLater(
    stream,
    emitsInOrder(statesWith(
      loading: type == OperationType.loading ? states : null,
      submission: type == OperationType.submission ? states : null,
      data: [initial, loaded ?? initial],
    )),
  );
}

Iterable<StatefulState<Data>> statesWith({
  List<OperationState>? loading,
  List<OperationState>? submission,
  List<Data?>? data,
}) {
  return [0, 1].map((i) => StatefulState<Data>(
        data: data?[i],
        loadingState: loading?[i] ?? OperationState.notStarted,
        submissionState: submission?[i] ?? OperationState.notStarted,
      ));
}
