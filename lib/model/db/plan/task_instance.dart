import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/duration.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'task_status.dart';

class TaskInstance {
	ObjectId id;
	ObjectId taskID;
	ObjectId planInstanceID;
	List<ObjectId> subtasks;

	int timer;
	TaskStatus status;
  List<Duration<TimeDate>> breaks;
  List<Duration<TimeDate>> duration;

  TaskInstance({this.id, this.taskID, this.planInstanceID, this.breaks, this.duration, this.status, this.subtasks, this.timer});

  factory TaskInstance.fromJson(Map<String, dynamic> json) {
    return TaskInstance(
      breaks: json['breaks'] != null ? (json['breaks'] as List).map((i) => Duration.fromJson(i)).toList() : null,
      duration: json['duration'] != null ? (json['duration'] as List).map((i) => Duration.fromJson(i)).toList() : null,
	    id: json['_id'],
      planInstanceID: json['planInstanceID'],
      status: json['status'] != null ? TaskStatus.fromJson(json['status']) : null,
      subtasks: json['subtasks'] != null ? new List<ObjectId>.from(json['subtasks']) : null,
      taskID: json['taskID'],
      timer: json['timer'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['planInstanceID'] = this.planInstanceID;
    data['taskID'] = this.taskID;
    data['timer'] = this.timer;
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
