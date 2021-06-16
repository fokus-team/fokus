import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../date/time_date.dart';
import '../date_span.dart';
import 'task.dart';
import 'task_status.dart';

class TaskInstance extends Equatable {
	final ObjectId? id;
	final ObjectId? taskID;
	final ObjectId? planInstanceID;
	final List<MapEntry<String, bool>>? subtasks;

	final bool? optional;
	final int? timer;
	final TaskStatus? status;
  final List<DateSpan<TimeDate>>? breaks;
  final List<DateSpan<TimeDate>>? duration;

  TaskInstance._({
	  this.id,
	  this.taskID,
	  this.planInstanceID,
	  this.breaks = const [],
	  this.duration = const [],
	  this.status,
	  this.optional,
	  this.subtasks = const [],
	  this.timer
  });

	TaskInstance.fromTask(Task task, ObjectId planInstanceID) : this._(id: ObjectId(), taskID: task.id, planInstanceID: planInstanceID,
			status: TaskStatus(completed: false, state: TaskState.notEvaluated), optional: task.optional,
			timer: task.timer, subtasks: task.subtasks?.map((subtask) => MapEntry(subtask, false)).toList());

  TaskInstance.fromJson(Json json) : this._(
    breaks: json['breaks'] != null ? (json['breaks'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)!).toList() : [],
    duration: json['duration'] != null ? (json['duration'] as List).map((i) => DateSpan.fromJson<TimeDate>(i)!).toList() : [],
    id: json['_id'],
    optional: json['optional'],
    planInstanceID: json['planInstanceID'],
    status: json['status'] != null ? TaskStatus.fromJson(json['status']) : null,
    subtasks: json['subtasks'] != null ? (json['subtasks'] as List).map((i) => MapEntry((i as Map).keys.first as String, i.values.first as bool)).toList() : [],
    taskID: json['taskID'],
    timer: json['timer'],
  );

  Json toJson() {
    final data = <String, dynamic>{};
    if (id != null)
      data['_id'] = id;
    if (planInstanceID != null)
      data['planInstanceID'] = planInstanceID;
    if (taskID != null)
      data['taskID'] = taskID;
    if (timer != null)
      data['timer'] = timer;
    if (optional != null)
      data['optional'] = optional;
    if (breaks != null)
      data['breaks'] = breaks!.map((v) => v.toJson()).toList();
    if (duration != null)
      data['duration'] = duration!.map((v) => v.toJson()).toList();
    if (status != null)
      data['status'] = status!.toJson();
    if (subtasks != null)
      data['subtasks'] = subtasks!.map((v) => {v.key: v.value}).toList();
    return data;
  }

  TaskInstance copyWith({List<DateSpan<TimeDate>>? breaks, List<DateSpan<TimeDate>>? duration}) {
  	return TaskInstance._(
		  breaks: breaks ?? this.breaks,
		  duration: duration ?? this.duration,
		  id: id,
		  optional: optional,
		  planInstanceID: planInstanceID,
		  status: status,
		  subtasks: subtasks,
		  taskID: taskID,
		  timer: timer,
	  );
  }

  @override
  List<Object?> get props => [id, taskID, planInstanceID, timer, optional, breaks, duration, status, subtasks];
}
