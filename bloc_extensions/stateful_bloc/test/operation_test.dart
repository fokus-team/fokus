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
      required ActionType type,
      Data? initial,
      Action<Data>? result = const Action.finish(),
      Object? error,
    }) async {
      await expectStates(
        stream: execute(
          state: state,
          type: type,
          body: () {
            if (error != null) throw error;
            return result;
          },
          initialData: initial,
          onError: errorHandler.onError,
        ),
        type: type,
        initial: initial,
        result: error == null ? result! : Action.fail(),
      );
      if (error == null) verifyZeroInteractions(errorHandler);
    }

    void testType(ActionType type) {
      group('On success', () {
        group('Emits correct states', () {
          test('when finish is used', () => testRun(type: type));
          test('when cancel is used', () => testRun(
            type: type,
            result: Action.cancel(),
          ));
          test('when fail is used', () => testRun(
            type: type,
            result: Action.fail(),
          ));
        });
        test('emits initial data', () {
          testRun(type: type, initial: Data.initial);
        });
        test('emits loaded data', () {
          testRun(type: type, result: Action.finish(Data.loaded));
        });
        test('combines initial & loaded data', () {
          testRun(
            type: type,
            initial: Data.initial,
            result: Action.finish(Data.loaded),
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

    group('Loading action', () => testType(ActionType.loading));
    group('Submission action', () => testType(ActionType.submission));
  });
}
