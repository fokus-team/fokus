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
/// (like showing a loading indicator on [ActionStatus.ongoing]
/// or an error message on [ActionStatus.failed]).
/// Your state is accessible in [StatefulState.data].
/// {@endtemplate}
///
/// Example usage:
/// ```dart
/// class PageBloc extends Bloc<PageEvent, StatefulState<PageData>>
///     with StatefulBloc {
///   PageBloc() : super(StatefulState());
///
///   @override
///   Stream<StatefulState> mapEventToState(PageEvent event) async* {
///     if (event is LoadEvent) {
///       yield* load(body: () {
///         // data loading
///         return Action.finish(PageData(/* data */));
///       });
///     }
///   }
/// }
/// ```
mixin StatefulBloc<Event, Data> on Bloc<Event, StatefulState<Data>> {
  /// {@template stateful_data}
  /// The current `state.data`
  /// {@endtemplate}
  Data? get data => state.data;

  /// {@template stateful_load}
  /// Wrapper for a user defined loading logic that handles state setting
  ///
  /// How it works:
  /// {@endtemplate}
  /// {@template stateful_flow}
  /// 1. If the status is already set to [ActionStatus.ongoing] it returns
  /// immediately, otherwise [ActionStatus.ongoing] status is set
  /// along with the `initialData` (if provided)
  /// 2. User provided `body` function is executed
  /// 3. Upon completion the [Action.data] is set (if provided) along
  /// with the final status determined by the [Action] constructor:
  ///     * [Action.finish] sets [ActionStatus.done]
  ///     (default if no value is returned)
  ///     * [Action.fail] sets [ActionStatus.failed]
  ///     * [Action.cancel] sets [ActionStatus.canceled]
  ///
  /// If anything is thrown from `body` a [ActionStatus.failed]
  /// status is set and the details are forwarded to [onError]
  /// {@endtemplate}
  @protected
  Stream<StatefulState<Data>> load({
    required FutureOr<Action<Data>?> Function() body,
    Data? initialData,
  }) async* {
    if (state.beingLoaded) return;
    yield* execute(
      state: state,
      type: ActionType.loading,
      body: body,
      onError: onError,
      initialData: initialData,
    );
  }

  /// {@template stateful_submit}
  /// Wrapper for a user defined submission logic that handles state setting
  ///
  /// How it works:
  /// {@endtemplate}
  /// {@macro stateful_flow}
  @protected
  Stream<StatefulState<Data>> submit({
    required FutureOr<Action<Data>?> Function() body,
    Data? initialData,
  }) async* {
    if (state.beingSubmitted) return;
    yield* execute(
      state: state,
      type: ActionType.submission,
      body: body,
      onError: onError,
      initialData: initialData,
    );
  }
}
