import 'package:stateful_bloc/src/stateful_base.dart';
import 'package:stateful_bloc/src/stateful_state.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import 'models.dart';
import 'utils.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(StackTrace.empty);
  });
  group('Stateful extension', () {
    late StatefulState<Data> state;
    final errorHandler = ErrorHandler();

    setUp(() {
      state = StatefulState<Data>();
      reset(errorHandler);
    });

    Future testRun({
      required OperationType type,
      Data? initial,
      Data? loaded,
      Object? error,
    }) async {
      await expectStates(
        stream: execute(
          state: state,
          type: type,
          body: () {
            if (error != null) throw error;
            return loaded;
          },
          initialState: initial,
          onError: errorHandler.onError,
        ),
        type: type,
        initial: initial,
        loaded: loaded,
        fails: error != null,
      );
      if (error == null) verifyZeroInteractions(errorHandler);
    }

    void testType(OperationType type) {
      group('On success', () {
        test('emits correct states', () => testRun(type: type));
        test('emits initial data', () {
          testRun(type: type, initial: Data.initial);
        });
        test('emits loaded data', () {
          testRun(type: type, loaded: Data.loaded);
        });
        test('combines initial & loaded data', () {
          testRun(
            type: type,
            initial: Data.initial,
            loaded: Data.loaded,
          );
        });
      });
      group('On failure', () {
        test('emits correct states', () async {
          await testRun(type: type, error: Exception());
        });
        test('triggers onError', () async {
          var error = Exception();
          await testRun(type: type, error: error);
          verify(() => errorHandler.onError(error, any())).called(1);
        });
        test('emits initial data', () {
          testRun(type: type, initial: Data.initial, error: Exception());
        });
      });
    }

    group('Loading operation', () => testType(OperationType.loading));
    group('Submission operation', () => testType(OperationType.submission));
  });
}
