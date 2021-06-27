import 'package:bloc/bloc.dart';
import 'package:bloc_extensions/bloc_extensions.dart';
import 'package:bloc_extensions/src/stateful/stateful_state.dart';
import 'package:mocktail/mocktail.dart';

enum Data { initial, loaded }
enum Event { load, simpleLoad, submit }

class ErrorHandler extends Mock {
  void onError(Object object, StackTrace stackTrace);
}

class TestCubit extends Cubit<StatefulState<Data>> with StatefulCubit {
  TestCubit() : super(StatefulState());

  Future loadData() => load(body: () {});
  Future submitData() => submit(body: () {});
}

class TestBloc extends Bloc<Event, StatefulState<Data>> with StatefulBloc {
  TestBloc() : super(StatefulState());

  @override
  Stream<StatefulState<Data>> mapEventToState(Event event) async* {
    if (event == Event.load) yield* load(body: () {});
    if (event == Event.simpleLoad) yield StatefulState(data: Data.loaded);
    if (event == Event.submit) yield* submit(body: () {});
  }
}

// ignore_for_file: must_call_super
class FailCubit extends Cubit<StatefulState<Data>> with StatefulCubit {
  final void Function(Object, StackTrace) callback;
  final Object error;

  FailCubit({required this.error, required this.callback})
      : super(StatefulState());

  Future failLoad() => load(body: () => throw error);
  Future failSubmit() => submit(body: () => throw error);

  @override
  void onError(Object error, StackTrace stack) => callback(error, stack);
}

class FailBloc extends Bloc<Event, StatefulState<Data>> with StatefulBloc {
  final void Function(Object, StackTrace) callback;
  final Object error;
  FailBloc({required this.error, required this.callback})
      : super(StatefulState());

  @override
  Stream<StatefulState<Data>> mapEventToState(Event event) async* {
    if (event == Event.load) yield* load(body: () => throw error);
    if (event == Event.submit) yield* submit(body: () => throw error);
  }

  @override
  void onError(Object error, StackTrace stack) => callback(error, stack);
}
