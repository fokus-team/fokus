import 'package:stateful_bloc/src/stateful_state.dart';
import 'package:stateful_bloc/stateful_bloc.dart';
import 'package:test/test.dart';

import 'models.dart';

Future expectStates({
  required ActionType type,
  required Stream<StatefulState<Data>> stream,
  Data? initial,
  Action<Data> result = const Action.finish(),
}) async {
  final statuses = [
    ActionStatus.ongoing,
    result.status,
  ];
  return expectLater(
    stream,
    emitsInOrder(statesWith(
      loading: type == ActionType.loading ? statuses : null,
      submission: type == ActionType.submission ? statuses : null,
      data: [initial, result.data ?? initial],
    )),
  );
}

Iterable<StatefulState<Data>> statesWith({
  List<ActionStatus>? loading,
  List<ActionStatus>? submission,
  List<Data?>? data,
}) {
  return [0, 1].map((i) => StatefulState<Data>(
        data: data?[i],
        loadingStatus: loading?[i] ?? ActionStatus.initial,
        submissionStatus: submission?[i] ?? ActionStatus.initial,
      ));
}
