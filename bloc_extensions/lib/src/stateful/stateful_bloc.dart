import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_base.dart';
import 'stateful_state.dart';

/// A bloc that abstracts and standardizes loading and submission operations
///
/// {@template stateful_description}
/// It provides a uniform state fields that can be acted upon by widgets
/// as well as [load] and [submit] method wrappers that set them.
/// {@endtemplate}
mixin StatefulBloc<Event, Data> on Bloc<Event, StatefulState<Data>> {
  /// {@template stateful_data}
  /// The current data - short form for `state.data`
  /// {@endtemplate}
  @protected
  Data? get data => state.data;

  @protected
  Stream<StatefulState<Data>> load({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async* {
    if (state.beingLoaded) return;
    yield* execute(
      state: state,
      type: OperationType.loading,
      body: body,
      initialState: initialState,
    );
  }

  @protected
  Stream<StatefulState<Data>> submit({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async* {
    if (state.beingSubmitted) return;
    yield* execute(
      state: state,
      type: OperationType.submission,
      body: body,
      initialState: initialState,
    );
  }
}
