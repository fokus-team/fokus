import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_base.dart';
import 'stateful_state.dart';

/// A cubit that abstracts and standardizes loading and submission operations
///
/// {@macro stateful_description}
mixin StatefulCubit<Data> on Cubit<StatefulState<Data>> {
  /// {@macro stateful_data}
  @protected
  Data? get data => state.data;

  @protected
  void emitData(Data data) => emit(state.copyWith(data: data));

  @protected
  Future load({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async {
    if (state.beingLoaded) return;
    return execute(
      state: state,
      type: OperationType.loading,
      body: body,
      initialState: initialState,
    ).forEach(emit);
  }

  @protected
  Future submit({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async {
    if (state.beingSubmitted) return;
    return execute(
      state: state,
      type: OperationType.submission,
      body: body,
      initialState: initialState,
    ).forEach(emit);
  }
}
