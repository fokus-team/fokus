import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
      taskInstances: json['taskInstances'] != null ? new List<ObjectId>.from(json['taskInstances']) : [],
	    tasks: json['tasks'] != null ? new List<ObjectId>.from(json['tasks']) : [],
	    addedTasks: json['addedTasks'] != null ? new List<ObjectId>.from(json['addedTasks']) : [],
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (id != null)
	    data['_id'] = this.id;
    if (planID != null)
	    data['planID'] = this.planID;
    if (state != null)
      data['state'] = this.state!.index;
    if (assignedTo != null)
      data['assignedTo'] = this.assignedTo;
    if (date != null)
      data['date'] = this.date!.toDBDate();
    if (this.duration != null)
	    data['duration'] = this.duration!.map((v) => v.toJson()).toList();
    if (this.taskInstances != null)
      data['taskInstances'] = this.taskInstances;
    if (this.addedTasks != null)
	    data['addedTasks'] = this.addedTasks;
    if (this.tasks != null)
	    data['tasks'] = this.tasks;
    return data;
  }
}
