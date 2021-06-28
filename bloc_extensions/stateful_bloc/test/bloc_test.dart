import 'package:stateful_bloc/src/stateful_state.dart';
import 'package:test/test.dart';

import 'models.dart';
import 'utils.dart';

void main() {
  group('Stateful extension', () {
    group('Cubit', () {
      late TestCubit cubit;

      setUp(() {
        cubit = TestCubit();
      });

      void testFailCubit(OperationType type) async {
        final error = Error();
        Object? expectedError;
        final cubit = FailCubit(
          error: error,
          callback: (error, _) => expectedError = error,
        );
        type == OperationType.loading ? cubit.failLoad() : cubit.failSubmit();
        await expectStates(
          stream: cubit.stream,
          type: type,
          fails: true,
        );
        expect(expectedError, error);
      }

      test('emits correct loading states', () {
        cubit.loadData();
        expectStates(stream: cubit.stream, type: OperationType.loading);
      });
      test('emits correct loading states', () {
        cubit.submitData();
        expectStates(stream: cubit.stream, type: OperationType.submission);
      });
      test('emitData updates data field', () {
        var state = cubit.state;
        cubit.emitData(Data.initial);
        expect(cubit.state, equals(state.copyWith(data: Data.initial)));
      });
      test('data returns current data field', () {
        expect(cubit.data, equals(null));
        cubit.emitData(Data.initial);
        expect(cubit.data, equals(Data.initial));
      });
      test('passes load errors to onError', () {
        testFailCubit(OperationType.loading);
      });
      test('passes submit errors to onError', () {
        testFailCubit(OperationType.submission);
      });
    });
    group('Bloc', () {
      late TestBloc bloc;

      setUp(() {
        bloc = TestBloc();
      });

      void testFailBloc(OperationType type) async {
        final error = Error();
        Object? expectedError;
        final bloc = FailBloc(
          error: error,
          callback: (error, _) => expectedError = error,
        );
        type == OperationType.loading
            ? bloc.add(Event.load)
            : bloc.add(Event.submit);
        await expectStates(
          stream: bloc.stream,
          type: type,
          fails: true,
        );
        expect(expectedError, error);
      }

      test('emits correct loading states', () {
        bloc.add(Event.load);
        expectStates(stream: bloc.stream, type: OperationType.loading);
      });
      test('emits correct submit states', () {
        bloc.add(Event.submit);
        expectStates(stream: bloc.stream, type: OperationType.submission);
      });
      test('data returns current data field', () async {
        expect(bloc.data, equals(null));
        bloc.add(Event.simpleLoad);
        await bloc.stream.first;
        expect(bloc.data, equals(Data.loaded));
      });
      test('passes load errors to onError', () {
        testFailBloc(OperationType.loading);
      });
      test('passes submit errors to onError', () {
        testFailBloc(OperationType.submission);
      });
    });
  });
}
