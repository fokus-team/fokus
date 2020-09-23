part of 'tasks_evaluation_cubit.dart';

abstract class TasksEvaluationState extends Equatable {
  const TasksEvaluationState();
}

class TasksEvaluationInitial extends TasksEvaluationState {
  @override
  List<Object> get props => [];
}

class TasksEvaluationLoadSuccess extends TasksEvaluationProvider {
  TasksEvaluationLoadSuccess(List<UITaskInstance> uiTaskInstances, List<UIChild> uiChildren, List<String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationSubmissionInProgress extends TasksEvaluationProvider {
  TasksEvaluationSubmissionInProgress(List<UITaskInstance> uiTaskInstances, List<UIChild> uiChildren, List<String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationSubmissionSuccess extends TasksEvaluationProvider {
  TasksEvaluationSubmissionSuccess(List<UITaskInstance> uiTaskInstances, List<UIChild> uiChildren, List<String> plansNames) : super(uiTaskInstances, uiChildren, plansNames);
}

class TasksEvaluationProvider extends TasksEvaluationState {
	final List<UITaskInstance> uiTaskInstances;
	final List<UIChild> uiChildren;
	final List<String> plansNames;

	TasksEvaluationProvider(this.uiTaskInstances, this.uiChildren, this.plansNames);

  @override
  List<Object> get props => [uiTaskInstances, uiChildren, plansNames];
}
