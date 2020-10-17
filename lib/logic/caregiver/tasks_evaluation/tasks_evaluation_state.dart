part of 'tasks_evaluation_cubit.dart';

class TasksEvaluationLoadSuccess extends TasksEvaluationBaseState {
  TasksEvaluationLoadSuccess(List<UITaskReport> reports) : super(reports);
}

class TasksEvaluationSubmissionInProgress extends TasksEvaluationBaseState {
  TasksEvaluationSubmissionInProgress(List<UITaskReport> reports) : super(reports);
}

class TasksEvaluationSubmissionSuccess extends TasksEvaluationBaseState {
  TasksEvaluationSubmissionSuccess(List<UITaskReport> reports) : super(reports);
}

class TasksEvaluationBaseState extends DataLoadSuccess {
	final List<UITaskReport> reports;

	TasksEvaluationBaseState(this.reports);

  @override
  List<Object> get props => [reports];
}
