import 'package:fokus/model/ui/plan/ui_task.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

enum PlanFormRepeatability { recurring, onlyOnce, untilCompleted }
enum PlanFormRepeatabilityRage { weekly, monthly }

class UIPlanForm {
	String name;
	List<Mongo.ObjectId> children = List<Mongo.ObjectId>();
	PlanFormRepeatability repeatability = PlanFormRepeatability.recurring;
	PlanFormRepeatabilityRage repeatabilityRage = PlanFormRepeatabilityRage.weekly;
	List<int> days = List<int>();
	DateTime onlyOnceDate;
	DateTime rangeFromDate;
	DateTime rangeToDate;
	bool isActive = true;

	List<UITask> tasks = List<UITask>();

	void setOnlyOnceDate(DateTime date) { onlyOnceDate = date; }
	void setRangeFromDate(DateTime date) { rangeFromDate = date; }
	void setRangeToDate(DateTime date) { rangeToDate = date; }

}
