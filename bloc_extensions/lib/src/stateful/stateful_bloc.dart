import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_state.dart';

mixin StatefulBloc<Event, Data> on Bloc<Event, StatefulState<Data>> {
  @protected
  Data? get data => state.data;

  @protected
  Stream<StatefulState<Data>> load({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async* {
    if (state.beingLoaded) return;
    yield state.copyWith(
      loadingState: OperationState.inProgress,
      data: initialState,
    );
    try {
      yield state.copyWith(
        data: await body(),
        loadingState: OperationState.success,
      );
    } on Exception {
      yield state.copyWith(loadingState: OperationState.failure);
      rethrow;
    }
  }

  @protected
  Stream<StatefulState<Data>> submit({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async* {
    if (!state.notSubmitted) return;
    yield state.copyWith(
      submissionState: OperationState.inProgress,
      data: initialState,
    );
    try {
      yield state.copyWith(
        data: await body(),
        submissionState: OperationState.success,
      );
    } on Exception {
      yield state.copyWith(
          submissionState: OperationState.failure);
      rethrow;
    }
  }
}
