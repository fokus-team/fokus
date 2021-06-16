import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/services/task_instance_service.dart';

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
  final int Function()? elapsedDuration;

  UITaskInstance({
    required this.instance,
	  required this.task,
	  TaskInstanceState? state,
    this.elapsedDuration = _defElapsedDuration,
  }) : state = state ?? TaskInstanceService.getSingleTaskInstanceStatus(
	  task: instance,
  );

  @override
  List<Object?> get props => [instance, task, state];

  static int _defElapsedDuration() => 0;
}
