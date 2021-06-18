import 'package:equatable/equatable.dart';

import '../../../services/model_helpers/task_instance_service.dart';
import '../../db/plan/task.dart';
import '../../db/plan/task_instance.dart';

enum TaskInstanceState {
  completed,
  available,
  inBreak,
  currentlyPerformed,
  rejected,
  queued,
  notCompletedUndefined
}

extension TaskInstanceStateGroups on TaskInstanceState {
  bool get inProgress => this == TaskInstanceState.inBreak || this == TaskInstanceState.currentlyPerformed;
  bool get wasInProgress => this == TaskInstanceState.rejected || this == TaskInstanceState.completed;
  bool get canBeStarted => this == TaskInstanceState.available || this == TaskInstanceState.rejected;
}

class UITaskInstance extends Equatable {
  final TaskInstance instance;
  final Task task;
  final TaskInstanceState? state;

  UITaskInstance({
    required this.instance,
	  required this.task,
	  TaskInstanceState? state,
  }) : state = state ?? TaskInstanceService.getSingleTaskInstanceStatus(
	  task: instance,
  );

  @override
  List<Object?> get props => [instance, task, state];
}
