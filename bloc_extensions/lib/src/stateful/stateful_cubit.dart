import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_state.dart';

mixin StatefulCubit<Data> on Cubit<StatefulState<Data>> {
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
    emit(state.copyWith(
      loadingState: OperationState.inProgress,
      data: initialState,
    ));
    try {
      emit(state.copyWith(
        data: await body(),
        loadingState: OperationState.success,
      ));
    } on Exception {
      emit(state.copyWith(loadingState: OperationState.failure));
      rethrow;
    }
  }

  @protected
  Future submit({
    required FutureOr<Data?> Function() body,
    Data? initialState,
  }) async {
    if (state.beingSubmitted) return;
    emit(state.copyWith(
      submissionState: OperationState.inProgress,
      data: initialState,
    ));
    try {
      emit(state.copyWith(
        data: await body(),
        submissionState: OperationState.success,
      ));
    } on Exception {
      emit(state.copyWith(
        submissionState: OperationState.failure,
      ));
      rethrow;
    }
  }
}
