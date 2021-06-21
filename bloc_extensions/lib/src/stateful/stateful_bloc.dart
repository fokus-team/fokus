import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'stateful_state.dart';

mixin StatefulBloc<Event, Data> on Bloc<Event, StatefulState<Data>> {
	@protected
	Data? get data => state.data;

	@protected
	Stream<StatefulState<Data>> load({required FutureOr<Data?> Function() body, Data? initialState}) async* {
		if (state.beingLoaded) return;
		yield state.copyWith(loadingState: DataLoadingState.loadingInProgress, data: initialState);
		try {
			yield state.copyWith(data: await body(), loadingState: DataLoadingState.loadSuccess);
		} on Exception {
			yield state.copyWith(loadingState: DataLoadingState.loadFailure);
			rethrow;
		}
	}

	@protected
	Stream<StatefulState<Data>> submit({required FutureOr<Data?> Function() body, Data? initialState}) async* {
		if (!state.notSubmitted) return;
		yield state.copyWith(submissionState: DataSubmissionState.submissionInProgress, data: initialState);
		try {
			yield state.copyWith(data: await body(), submissionState: DataSubmissionState.submissionSuccess);
		} on Exception {
			yield state.copyWith(submissionState: DataSubmissionState.submissionFailure);
			rethrow;
		}
	}
}
