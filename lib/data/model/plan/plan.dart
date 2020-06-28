import 'package:fokus/data/model/date/date.dart';
import 'package:fokus/data/model/date/time_date.dart';
import 'package:fokus/data/model/plan/plan_repeatability.dart';

class Plan {
  bool active;
  List<String> assignedTo;
  List<Date> changedInstances;
  TimeDate createdAt;
  String createdBy;
  String ID;
  List<String> instances;
  String name;
  PlanRepeatability repeatability;
  List<String> tasks;

  Plan(
      {this.active,
      this.assignedTo,
      this.changedInstances,
      this.createdAt,
      this.createdBy,
      this.ID,
      this.instances,
      this.name,
      this.repeatability,
      this.tasks});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      active: json['active'],
      assignedTo: json['assignedTo'] != null ? new List<String>.from(json['assignedTo']) : null,
      changedInstances: json['changedInstances'] != null ? (json['changedInstances'] as List).map((date) => Date.parseDBString(date)) : null,
      createdAt: TimeDate.parseDBString(json['createdAt']),
      createdBy: json['createdBy'],
      ID: json['ID'],
      instances: json['instances'] != null ? new List<String>.from(json['instances']) : null,
      name: json['name'],
      repeatability: PlanRepeatability.fromJson(json['repeatability']),
      tasks: json['tasks'] != null ? new List<String>.from(json['tasks']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active'] = this.active;
    data['createdAt'] = this.createdAt.toDBString();
    data['createdBy'] = this.createdBy;
    data['ID'] = this.ID;
    data['name'] = this.name;
    data['repeatability'] = this.repeatability.toJson();
    if (this.assignedTo != null) {
      data['assignedTo'] = this.assignedTo;
    }
    if (this.changedInstances != null) {
      data['changedInstances'] = this.changedInstances.map((e) => e.toDBString()).toList();
    }
    if (this.instances != null) {
      data['instances'] = this.instances;
    }
    if (this.tasks != null) {
      data['tasks'] = this.tasks;
    }
    return data;
  }
}
