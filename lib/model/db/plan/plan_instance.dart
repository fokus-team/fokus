import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../date/date.dart';
import '../date/time_date.dart';
import '../date_span.dart';
import 'plan.dart';
import 'plan_instance_state.dart';

class PlanInstance {
	ObjectId? id;
	ObjectId? planID;
	ObjectId? assignedTo;

  Date? date;
	PlanInstanceState? state;
	List<DateSpan<TimeDate>>? duration;
	List<ObjectId>? tasks;
	List<ObjectId>? addedTasks;
  List<ObjectId>? taskInstances;

	PlanInstance.fromPlan(Plan plan, {ObjectId? assignedTo, Date? date, PlanInstanceState? state}) : this._(id: ObjectId(),
			tasks: plan.tasks, planID: plan.id, date: date ?? Date.now(), state: state ?? PlanInstanceState.notStarted, assignedTo: assignedTo);
  PlanInstance._({this.id, this.taskInstances, this.planID, this.assignedTo, this.date, this.state, this.duration, this.tasks, this.addedTasks});

  static PlanInstance? fromJson(Json? json) {
    return json != null ? PlanInstance._(
	    id: json['_id'],
	    state: json['state'] != null ? PlanInstanceState.values[json['state']] : null,
	    planID: json['planID'],
      assignedTo: json['assignedTo'],
      date: Date.parseDBDate(json['date']),
	    duration: json['duration'] != null ? (json['duration'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)!).toList() : [],
      taskInstances: json['taskInstances'] != null ? List<ObjectId>.from(json['taskInstances']) : [],
	    tasks: json['tasks'] != null ? List<ObjectId>.from(json['tasks']) : [],
	    addedTasks: json['addedTasks'] != null ? List<ObjectId>.from(json['addedTasks']) : [],
    ) : null;
  }

  Json toJson() {
    final data = <String, dynamic>{};
    if (id != null)
	    data['_id'] = id;
    if (planID != null)
	    data['planID'] = planID;
    if (state != null)
      data['state'] = state!.index;
    if (assignedTo != null)
      data['assignedTo'] = assignedTo;
    if (date != null)
      data['date'] = date!.toDBDate();
    if (duration != null)
	    data['duration'] = duration!.map((v) => v.toJson()).toList();
    if (taskInstances != null)
      data['taskInstances'] = taskInstances;
    if (addedTasks != null)
	    data['addedTasks'] = addedTasks;
    if (tasks != null)
	    data['tasks'] = tasks;
    return data;
  }
}
