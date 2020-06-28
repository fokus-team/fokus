import 'package:fokus/data/model/gamification/points.dart';

class Task {
  String description;
  String ID;
  String name;
  bool optional;
  String planID;
  Points points;
  List<String> subtasks;
  int timer;

  Task({this.description, this.ID, this.name, this.optional, this.planID, this.points, this.subtasks, this.timer});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      description: json['description'],
      ID: json['ID'],
      name: json['name'],
      optional: json['optional'],
      planID: json['planID'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
      subtasks: json['subtasks'] != null ? new List<String>.from(json['subtasks']) : null,
      timer: json['timer'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['ID'] = this.ID;
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
