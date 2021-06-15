import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

enum PlanFormRepeatability { recurring, onlyOnce, untilCompleted }
enum PlanFormRepeatabilityRage { weekly, monthly }

extension PlanFormRepeatabilityRageDbType on PlanFormRepeatabilityRage {
	RepeatabilityType get dbType => const {
		PlanFormRepeatabilityRage.weekly: RepeatabilityType.weekly,
		PlanFormRepeatabilityRage.monthly: RepeatabilityType.monthly,
	}[this]!;
}

// ignore: must_be_immutable
class PlanFormModel extends Equatable {
	String? name;
	List<ObjectId> children = [];
	PlanFormRepeatability repeatability = PlanFormRepeatability.recurring;
	PlanFormRepeatabilityRage repeatabilityRage = PlanFormRepeatabilityRage.weekly;
	List<int> days = [];
	Date? onlyOnceDate = Date.now();
	DateSpan<Date> rangeDate = DateSpan();
	bool isActive = true;
	List<TaskFormModel> tasks = [];

	PlanFormModel();

	PlanFormModel.fromDBModel(Plan plan) : name = plan.name, children = plan.assignedTo!, days = plan.repeatability!.days ?? [],
			repeatability = PlanRepeatabilityService.getFormRepeatability(plan.repeatability!),
			repeatabilityRage = plan.repeatability!.type == RepeatabilityType.monthly ? PlanFormRepeatabilityRage.monthly : PlanFormRepeatabilityRage.weekly,
			onlyOnceDate = plan.repeatability!.range!.from ?? Date.now(), rangeDate = plan.repeatability!.range!, isActive = plan.active!;

	PlanFormModel.from(PlanFormModel model) : name = model.name, children = List.from(model.children), days = List.from(model.days),
			repeatability = model.repeatability, repeatabilityRage = model.repeatabilityRage, onlyOnceDate = Date.fromDate(model.onlyOnceDate!),
			rangeDate = DateSpan.from(model.rangeDate), isActive = model.isActive, tasks = List.from(model.tasks.map((task) => TaskFormModel.from(task)));

	void setOnlyOnceDate(DateTime? date) => onlyOnceDate = date != null ? Date.fromDate(date) : null;
	void setRangeFromDate(DateTime? date) => rangeDate = rangeDate.copyWith(from: date != null ? Date.fromDate(date) : null);
	void setRangeToDate(DateTime? date) => rangeDate = rangeDate.copyWith(to: date != null ? Date.fromDate(date) : null);

	@override
	List<Object?> get props => [name, children, repeatability, repeatabilityRage, days, onlyOnceDate, rangeDate, isActive, tasks];
}
