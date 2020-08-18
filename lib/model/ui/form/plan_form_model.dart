import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

enum PlanFormRepeatability { recurring, onlyOnce, untilCompleted }
enum PlanFormRepeatabilityRage { weekly, monthly }

extension PlanFormRepeatabilityRageDbType on PlanFormRepeatabilityRage {
	RepeatabilityType get dbType => const {
		PlanFormRepeatabilityRage.weekly: RepeatabilityType.weekly,
		PlanFormRepeatabilityRage.monthly: RepeatabilityType.monthly,
	}[this];
}

class PlanFormModel {
	String name;
	List<Mongo.ObjectId> children = List<Mongo.ObjectId>();
	PlanFormRepeatability repeatability = PlanFormRepeatability.recurring;
	PlanFormRepeatabilityRage repeatabilityRage = PlanFormRepeatabilityRage.weekly;
	List<int> days = List<int>();
	Date onlyOnceDate = Date.now();
	DateSpan<Date> rangeDate = DateSpan();
	bool isActive = true;

	PlanFormModel();

	PlanFormModel.fromDBModel(Plan plan) : name = plan.name, children = plan.assignedTo, days = plan.repeatability.days ?? [],
			repeatability = PlanRepeatabilityService.getFormRepeatability(plan.repeatability),
			repeatabilityRage = plan.repeatability.type == RepeatabilityType.monthly ? PlanFormRepeatabilityRage.monthly : PlanFormRepeatabilityRage.weekly,
			onlyOnceDate = plan.repeatability.range.from ?? Date.now(), rangeDate = plan.repeatability.range, isActive = plan.active;

	List<TaskFormModel> tasks = List<TaskFormModel>();

	void setOnlyOnceDate(DateTime date) { onlyOnceDate = date != null ? Date.fromDate(date) : null; }
	void setRangeFromDate(DateTime date) { rangeDate.from = date != null ? Date.fromDate(date) : null; }
	void setRangeToDate(DateTime date) { rangeDate.to = date != null ? Date.fromDate(date) : null; } 

	bool isDataChanged() {
		return name != null ||
		children.isNotEmpty ||
		repeatability != PlanFormRepeatability.recurring ||
		repeatabilityRage != PlanFormRepeatabilityRage.weekly ||
		days.isNotEmpty ||
		onlyOnceDate != Date.now() ||
		rangeDate.from != null ||
		rangeDate.to != null ||
		!isActive ||
		tasks.isNotEmpty;
	}

}
