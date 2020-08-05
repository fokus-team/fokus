import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'plan_instance_state.dart';

class PlanInstance {
	ObjectId id;
	ObjectId planID;
	ObjectId assignedTo;

  Date date;
	PlanInstanceState state;
	List<DateSpan<TimeDate>> duration;
	List<ObjectId> tasks;
	List<ObjectId> addedTasks;
  List<ObjectId> taskInstances;

  PlanInstance({this.id, this.taskInstances, this.planID, this.assignedTo, this.date, this.state, this.duration, this.tasks, this.addedTasks});

  factory PlanInstance.fromJson(Map<String, dynamic> json) {
    return json != null ? PlanInstance(
	    id: json['_id'],
	    state: json['state'] != null ? PlanInstanceState.values[json['state']] : null,
	    planID: json['planID'],
      assignedTo: json['assignedTo'],
      date: Date.parseDBDate(json['date']),
	    duration: json['duration'] != null ? (json['duration'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)).toList() : [],
      taskInstances: json['instances'] != null ? new List<ObjectId>.from(json['taskInstances']) : [],
	    tasks: json['tasks'] != null ? new List<ObjectId>.from(json['tasks']) : [],
	    addedTasks: json['addedTasks'] != null ? new List<ObjectId>.from(json['addedTasks']) : [],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['planID'] = this.planID;
    data['state'] = this.state.index;
    data['assignedTo'] = this.assignedTo;
    data['date'] = this.date.toDBDate();
    if (this.duration != null) {
	    data['duration'] = this.duration.map((v) => v.toJson()).toList();
    }
    if (this.taskInstances != null) {
      data['taskInstances'] = this.taskInstances;
    }
    if (this.addedTasks != null) {
	    data['addedTasks'] = this.addedTasks;
    }
    if (this.tasks != null) {
	    data['tasks'] = this.tasks;
    }
    return data;
  }
}
