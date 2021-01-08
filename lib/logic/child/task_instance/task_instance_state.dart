part of 'task_instance_cubit.dart';

abstract class TaskInstanceState extends Equatable {
  const TaskInstanceState();
}

class TaskInstanceStateInitial extends TaskInstanceState {
	final UIPlanInstance planInstance;

  TaskInstanceStateInitial(this.planInstance);

	@override
  List<Object> get props => [planInstance];
}

class TaskInstanceInBreak extends TaskInstanceLoaded {
  TaskInstanceInBreak(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceInProgress extends TaskInstanceLoaded {
  TaskInstanceInProgress(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);

  TaskInstanceInProgress copyWith({UITaskInstance taskInstance}) {
  	return TaskInstanceInProgress(
		  taskInstance ?? this.taskInstance,
		  planInstance
	  );
  }
}

class TaskInstanceDone extends TaskInstanceLoaded {
  TaskInstanceDone(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceRejected extends TaskInstanceLoaded {
  TaskInstanceRejected(UITaskInstance taskInstance, UIPlanInstance planInstance) : super(taskInstance, planInstance);
}

class TaskInstanceLoaded extends TaskInstanceState {
	final UITaskInstance taskInstance;
	final UIPlanInstance planInstance;

  TaskInstanceLoaded(this.taskInstance, this.planInstance);

  @override
  List<Object> get props => [this.taskInstance, this.planInstance];

}
