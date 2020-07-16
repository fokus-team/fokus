import 'package:fokus/model/db/gamification/points.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Task {
	String name;
  String description;
  ObjectId id;
  ObjectId planID;
	List<ObjectId> subtasks;

  bool optional;
  Points points;
  int timer;

  Task({this.description, this.id, this.name, this.optional, this.planID, this.points, this.subtasks, this.timer});

  factory Task.fromJson(Map<ObjectId, dynamic> json) {
    return Task(
      description: json['description'],
	    id: json['_id'],
      name: json['name'],
      optional: json['optional'],
      planID: json['planID'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
      subtasks: json['subtasks'] != null ? new List<ObjectId>.from(json['subtasks']) : [],
      timer: json['timer'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['_id'] = this.id;
    data['name'] = this.name;
    data['optional'] = this.optional;
    data['planID'] = this.planID;
    data['timer'] = this.timer;
    if (this.points != null) {
      data['points'] = this.points.toJson();
    }
    if (this.subtasks != null) {
      data['subtasks'] = this.subtasks;
    }
    return data;
  }
}
