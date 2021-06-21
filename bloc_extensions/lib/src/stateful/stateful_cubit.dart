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
	Future load({required FutureOr<Data?> Function() body, Data? initialState}) async {
		if (state.beingLoaded) return;
		emit(state.copyWith(loadingState: DataLoadingState.loadingInProgress, data: initialState));
		try {
			emit(state.copyWith(data: await body(), loadingState: DataLoadingState.loadSuccess));
		} on Exception {
			emit(state.copyWith(loadingState: DataLoadingState.loadFailure));
			rethrow;
		}
	}

	@protected
	Future submit({required FutureOr<Data?> Function() body, Data? initialState}) async {
		if (state.beingSubmitted) return;
		emit(state.copyWith(submissionState: DataSubmissionState.submissionInProgress, data: initialState));
		try {
			emit(state.copyWith(data: await body(), submissionState: DataSubmissionState.submissionSuccess));
		} on Exception {
			emit(state.copyWith(submissionState: DataSubmissionState.submissionFailure));
			rethrow;
		}
	}
}
