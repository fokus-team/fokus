import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_base.dart';
import 'stateful_state.dart';

/// A bloc that abstracts and handles loading and submission states
///
/// {@template stateful_description}
/// Simplifies state management by handling its status.
/// It's designed to be easily integrable and flexible extension
/// that automatically tracks and sets the commonly used page state
/// types using enum fields instead of the usual inheritance tree.
///
/// Whether you need a loading behaviour, submission or both just by:
/// * mixing with [StatefulBloc] / [StatefulCubit]
/// * wrapping your state with [StatefulState]
/// * wrapping your logic with [load] / [submit]
///
/// you can react to the current status in your widgets
/// (Like showing a loading indicator on [OperationState.inProgress]
/// or an error message on [OperationState.failure]).
/// Your state is accessible in [StatefulState.data].
/// {@endtemplate}
///
/// Example usage:
/// ```dart
/// class PageBloc extends Bloc<PageEvent, StatefulState<PageData>>
///     with StatefulBloc {
///   @override
///   Stream<StatefulState> mapEventToState(PageEvent event) async* {
///     if (event is LoadEvent) {
///       yield* load(body: () {
///         return PageData(...);
///       });
///     }
///   }
/// }
/// ```
mixin StatefulBloc<Event, Data> on Bloc<Event, StatefulState<Data>> {
  /// {@template stateful_data}
  /// The current `state.data`
  /// {@endtemplate}
  @protected
  Data? get data => state.data;

  /// {@template stateful_load}
  /// Wrapper for a user defined loading logic that emits its status
  ///
  /// How it works:
  /// {@endtemplate}
  /// {@template stateful_flow}
  /// 1. [OperationState.inProgress] status is set
  /// along with the `initialState` (if its provided)
  /// 2. User provided `data` function is executed
  /// 3. Depending on the outcome:
  ///     * If it completes successfully [OperationState.success] status
  ///     is set along with the returned loaded data (if its provided)
  ///     * If anything is thrown [OperationState.failure] status
  ///     is set and the details are forwarded to [onError]
  /// {@endtemplate}
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
      onError: onError,
      initialState: initialState,
    );
  }

  /// {@template stateful_submit}
  /// Wrapper for a user defined submission logic that emits its status
  ///
  /// How it works:
  /// {@endtemplate}
  /// {@macro stateful_flow}
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
      onError: onError,
      initialState: initialState,
    );
  }
}
