import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/ui/plan/ui_task.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

enum PlanFormRepeatability { recurring, onlyOnce, untilCompleted }
enum PlanFormRepeatabilityRage { weekly, monthly }

extension PlanFormRepeatabilityRageDbType on PlanFormRepeatabilityRage {
	RepeatabilityType get dbType => const {
		PlanFormRepeatabilityRage.weekly: RepeatabilityType.weekly,
		PlanFormRepeatabilityRage.monthly: RepeatabilityType.monthly,
	}[this];
}

class UIPlanForm {
	String name;
	List<Mongo.ObjectId> children = List<Mongo.ObjectId>();
	PlanFormRepeatability repeatability = PlanFormRepeatability.recurring;
	PlanFormRepeatabilityRage repeatabilityRage = PlanFormRepeatabilityRage.weekly;
	List<int> days = List<int>();
	Date onlyOnceDate = Date.now();
	DateSpan<Date> rangeDate = DateSpan();
	bool isActive = true;

	List<UITask> tasks = List<UITask>();

	void setOnlyOnceDate(DateTime date) { onlyOnceDate = date != null ? Date.fromDate(date) : null; }
	void setRangeFromDate(DateTime date) { rangeDate.from = date != null ? Date.fromDate(date) : null; }
	void setRangeToDate(DateTime date) { rangeDate.to = date != null ? Date.fromDate(date) : null; } 

}
