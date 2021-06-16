import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';


class Task extends Equatable {
	final String? name;
  final String? description;
  final ObjectId? id;
  final ObjectId? planID;
	final List<String>? subtasks;

  final bool? optional;
  final Points? points;
  final int? timer;

  Task.fromTaskForm({required TaskFormModel taskForm, ObjectId? planID, ObjectId? createdBy, ObjectId? taskID}) : this(
	  name: taskForm.title, 
	  description: taskForm.description, 
	  planID: planID, 
	  subtasks: taskForm.subtasks,
	  optional: taskForm.optional, 
	  timer: taskForm.timer! > 0 ? taskForm.timer : null, 
	  id: taskID ?? ObjectId(),
	  points: taskForm.pointsValue != null ? Points.fromCurrency(currency: taskForm.pointCurrency!, quantity: taskForm.pointsValue!, createdBy: createdBy) : null
  );

  Task({this.description, this.id, this.name, this.optional, this.planID, this.points, this.subtasks, this.timer = 0});

  Task.fromJson(Json json) : this(
      description: json['description'],
	    id: json['_id'],
      name: json['name'],
      optional: json['optional'],
      planID: json['planID'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
      subtasks: json['subtasks'] != null ? new List<String>.from(json['subtasks']) : [],
      timer: json['timer'],
    );

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

	@override
	List<Object?> get props => [id, description, name, optional, planID, timer, points, subtasks];
}
