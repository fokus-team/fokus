part of 'task_instance_cubit.dart';

abstract class TaskInstanceState extends Equatable {
  const TaskInstanceState();
}

class TaskInstanceStateInitial extends TaskInstanceState {
  @override
  List<Object> get props => [];
}

class TaskInstanceStateSubtaskChanged extends TaskInstanceStateProgress {
  TaskInstanceStateSubtaskChanged(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceStateBreak extends TaskInstanceProvider {
  TaskInstanceStateBreak(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceStateProgress extends TaskInstanceProvider {
  TaskInstanceStateProgress(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceStateDone extends TaskInstanceProvider {
  TaskInstanceStateDone(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceStateRejected extends TaskInstanceProvider {
  TaskInstanceStateRejected(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceProvider extends TaskInstanceState {
	final UITaskInstance taskInstance;
	final UIPlanInstance planInstance;

  TaskInstanceProvider(this.taskInstance, this.planInstance);

  @override
  List<Object> get props => [this.taskInstance, this.planInstance];

}
