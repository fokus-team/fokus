import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'child_tasks_state.dart';

class ChildTasksCubit extends Cubit<ChildTasksState> {
  ChildTasksCubit() : super(ChildTasksInitial());
}
