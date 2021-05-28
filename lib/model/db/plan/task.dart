import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';


class Task {
	String? name;
  String? description;
  ObjectId? id;
  ObjectId? planID;
	List<String>? subtasks;

  bool? optional;
  Points? points;
  int? timer;

  Task.fromTaskForm(TaskFormModel taskForm, ObjectId planId, ObjectId creator, [ObjectId? taskID])
		    : this._(name: taskForm.title, description: taskForm.description, planID: planId, subtasks: taskForm.subtasks,
		  optional: taskForm.optional, timer: taskForm.timer! > 0 ? taskForm.timer : null, id: taskID ?? ObjectId(),
		  points: taskForm.pointsValue != null ? Points.fromUICurrency(taskForm.pointCurrency!, taskForm.pointsValue!, creator: creator) : null);

  Task._({this.description, this.id, this.name, this.optional, this.planID, this.points, this.subtasks, this.timer});

  static Task? fromJson(Json? json) {
    return json != null ? Task._(
      description: json['description'],
	    id: json['_id'],
      name: json['name'],
      optional: json['optional'],
      planID: json['planID'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
      subtasks: json['subtasks'] != null ? new List<String>.from(json['subtasks']) : [],
      timer: json['timer'],
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (this.description != null)
      data['description'] = this.description;
    if (this.id != null)
      data['_id'] = this.id;
    if (this.name != null)
      data['name'] = this.name;
    if (this.optional != null)
      data['optional'] = this.optional;
    if (this.planID != null)
      data['planID'] = this.planID;
    if (this.timer != null)
      data['timer'] = this.timer;
    if (this.points != null)
      data['points'] = this.points!.toJson();
    if (this.subtasks != null)
      data['subtasks'] = this.subtasks;
    return data;
  }
}
