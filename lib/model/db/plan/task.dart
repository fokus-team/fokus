import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../../ui/form/task_form_model.dart';
import '../gamification/points.dart';


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
      subtasks: json['subtasks'] != null ? List<String>.from(json['subtasks']) : [],
      timer: json['timer'],
    );

  Json toJson() {
    final data = <String, dynamic>{};
    if (description != null)
      data['description'] = description;
    if (id != null)
      data['_id'] = id;
    if (name != null)
      data['name'] = name;
    if (optional != null)
      data['optional'] = optional;
    if (planID != null)
      data['planID'] = planID;
    if (timer != null)
      data['timer'] = timer;
    if (points != null)
      data['points'] = points!.toJson();
    if (subtasks != null)
      data['subtasks'] = subtasks;
    return data;
  }

	@override
	List<Object?> get props => [id, description, name, optional, planID, timer, points, subtasks];
}
