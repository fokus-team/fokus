import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_base.dart';
import 'stateful_state.dart';

/// A cubit that abstracts and handles loading and submission states
///
/// {@macro stateful_description}
///
/// Example usage:
/// ```dart
/// class PageCubit extends Cubit<StatefulState<PageData>> with StatefulCubit {
///   void loadPage() => load(body: () {
///     return PageData(...);
///   });
/// }
/// ```
mixin StatefulCubit<Data> on Cubit<StatefulState<Data>> {
  /// {@macro stateful_data}
  Data? get data => state.data;

  /// Emits a state with passed [data] emulating the [emit] of a normal [Cubit]
  ///
  /// Short form for `emit(state.copyWith(data: data))`.
  void emitData(Data data) => emit(state.copyWith(data: data));

  /// {@macro stateful_load}
  ///
  /// {@macro stateful_flow}
  @protected
  Future load({
    required FutureOr<Action<Data>?> Function() body,
    Data? initialData,
  }) async {
    if (state.beingLoaded) return;
    return execute(
      state: state,
      type: ActionType.loading,
      body: body,
      onError: onError,
      initialData: initialData,
    ).forEach(emit);
  }

  /// {@macro stateful_submit}
  ///
  /// {@macro stateful_flow}
  @protected
  Future submit({
    required FutureOr<Action<Data>?> Function() body,
    Data? initialData,
  }) async {
    if (state.beingSubmitted) return;
    return execute(
      state: state,
      type: ActionType.submission,
      body: body,
      onError: onError,
      initialData: initialData,
    ).forEach(emit);
  }
}
