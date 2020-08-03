
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

	List<UITaskForm> tasks = List<UITaskForm>();

	UIPlanForm() {
		tasks.add(UITaskForm(title: 'Aaaa'));
		tasks.add(UITaskForm(title: 'Bbbb'));
		tasks.add(UITaskForm(title: 'Cccc'));
	}

}

class UITaskForm {
	String title;
	UITaskForm({this.title});
}
