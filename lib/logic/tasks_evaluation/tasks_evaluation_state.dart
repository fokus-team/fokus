part of 'tasks_evaluation_cubit.dart';

abstract class TasksEvaluationState extends Equatable {
  const TasksEvaluationState();
}

class TasksEvaluationInitial extends TasksEvaluationState {
  @override
  List<Object> get props => [];
}

class TasksEvaluationLoadSuccess extends TasksEvaluationProvider {
  TasksEvaluationLoadSuccess(List<UITaskInstance> uiTaskInstances,  Map<ObjectId, UIChild> uiChildren, Map<ObjectId, String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationSubmissionInProgress extends TasksEvaluationProvider {
  TasksEvaluationSubmissionInProgress(List<UITaskInstance> uiTaskInstances,  Map<ObjectId, UIChild> uiChildren, Map<ObjectId, String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationSubmissionSuccess extends TasksEvaluationProvider {
  TasksEvaluationSubmissionSuccess(List<UITaskInstance> uiTaskInstances, Map<ObjectId, UIChild> uiChildren, Map<ObjectId, String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationProvider extends TasksEvaluationState {
	final List<UITaskInstance> uiTaskInstances;
	final Map<ObjectId, UIChild> uiChildren;
	final Map<ObjectId, String> plansNames;

	TasksEvaluationProvider(this.uiTaskInstances, this.uiChildren, this.plansNames);

  @override
  List<Object> get props => [uiTaskInstances, uiChildren, plansNames];
}
