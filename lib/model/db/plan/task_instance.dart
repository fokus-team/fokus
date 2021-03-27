// @dart = 2.10
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'task_status.dart';

class TaskInstance {
	ObjectId id;
	ObjectId taskID;
	ObjectId planInstanceID;
	List<MapEntry<String, bool>> subtasks;

	bool optional;
	int timer;
	TaskStatus status;
  List<DateSpan<TimeDate>> breaks;
  List<DateSpan<TimeDate>> duration;

  TaskInstance._({this.id, this.taskID, this.planInstanceID, this.breaks, this.duration, this.status, this.optional, this.subtasks, this.timer});
	TaskInstance.fromTask(Task task, ObjectId planInstanceId) : this._(id: ObjectId(), taskID: task.id, planInstanceID: planInstanceId, status: TaskStatus(completed: false, state: TaskState.notEvaluated), optional: task.optional, timer: task.timer, subtasks: task.subtasks.map((subtask) => MapEntry(subtask, false)).toList());

  factory TaskInstance.fromJson(Map<String, dynamic> json) {
    return json != null ? TaskInstance._(
      breaks: json['breaks'] != null ? (json['breaks'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)).toList() : [],
      duration: json['duration'] != null ? (json['duration'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)).toList() : [],
	    id: json['_id'],
	    optional: json['optional'],
      planInstanceID: json['planInstanceID'],
      status: json['status'] != null ? TaskStatus.fromJson(json['status']) : null,
      subtasks: json['subtasks'] != null ? (json['subtasks'] as List).map((i) => MapEntry((i as Map).keys.first as String, (i as Map).values.first as bool)).toList() : [],
      taskID: json['taskID'],
      timer: json['timer'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null)
      data['_id'] = this.id;
    if (this.planInstanceID != null)
      data['planInstanceID'] = this.planInstanceID;
    if (this.taskID != null)
      data['taskID'] = this.taskID;
    if (this.timer != null)
      data['timer'] = this.timer;
    if (this.optional != null)
      data['optional'] = this.optional;
    if (this.breaks != null)
      data['breaks'] = this.breaks.map((v) => v.toJson()).toList();
    if (this.duration != null)
      data['duration'] = this.duration.map((v) => v.toJson()).toList();
    if (this.status != null)
      data['status'] = this.status.toJson();
    if (this.subtasks != null)
      data['subtasks'] = this.subtasks.map((v) => {v.key: v.value}).toList();
    return data;
  }
}
