import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'task_status.dart';

class TaskInstance {
	ObjectId id;
	ObjectId taskID;
	ObjectId planInstanceID;
	List<ObjectId> subtasks;

	bool optional;
	int timer;
	TaskStatus status;
  List<DateSpan<TimeDate>> breaks;
  List<DateSpan<TimeDate>> duration;

  TaskInstance({this.id, this.taskID, this.planInstanceID, this.breaks, this.duration, this.status, bool optional, this.subtasks, this.timer});

  factory TaskInstance.fromJson(Map<String, dynamic> json) {
    return json != null ? TaskInstance(
      breaks: json['breaks'] != null ? (json['breaks'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)).toList() : [],
      duration: json['duration'] != null ? (json['duration'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)).toList() : [],
	    id: json['_id'],
	    optional: json['optional'],
      planInstanceID: json['planInstanceID'],
      status: json['status'] != null ? TaskStatus.fromJson(json['status']) : null,
      subtasks: json['subtasks'] != null ? new List<ObjectId>.from(json['subtasks']) : [],
      taskID: json['taskID'],
      timer: json['timer'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['planInstanceID'] = this.planInstanceID;
    data['taskID'] = this.taskID;
    data['timer'] = this.timer;
    data['optional'] = this.optional;
    if (this.breaks != null) {
      data['breaks'] = this.breaks.map((v) => v.toJson()).toList();
    }
    if (this.duration != null) {
      data['duration'] = this.duration.map((v) => v.toJson()).toList();
    }
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    if (this.subtasks != null) {
      data['subtasks'] = this.subtasks;
    }
    return data;
  }
}
