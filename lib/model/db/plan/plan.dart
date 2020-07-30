import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Plan {
  ObjectId id;
  String name;
  bool active;

  PlanRepeatability repeatability;
  List<Date> changedInstances;
  TimeDate createdAt;
  ObjectId createdBy;

  List<ObjectId> tasks;
  List<ObjectId> instances;
  List<ObjectId> assignedTo;

  Plan(
      {this.active,
      this.assignedTo,
      this.changedInstances,
      this.createdAt,
      this.createdBy,
      this.id,
      this.instances,
      this.name,
      this.repeatability,
      this.tasks});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return json != null ? Plan(
      active: json['active'],
      assignedTo: json['assignedTo'] != null ? new List<ObjectId>.from(json['assignedTo']) : [],
      changedInstances: json['changedInstances'] != null ? (json['changedInstances'] as List).map((date) => Date.parseDBDate(date)) : [],
      createdAt: TimeDate.parseDBDate(json['createdAt']),
      createdBy: json['createdBy'],
      id: json['_id'],
      instances: json['instances'] != null ? new List<ObjectId>.from(json['instances']) : [],
      name: json['name'],
      repeatability: PlanRepeatability.fromJson(json['repeatability']),
      tasks: json['tasks'] != null ? new List<ObjectId>.from(json['tasks']) : [],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['active'] = this.active;
    data['createdAt'] = this.createdAt.toDBDate();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.id;
    data['name'] = this.name;
    data['repeatability'] = this.repeatability.toJson();
    if (this.assignedTo != null) {
      data['assignedTo'] = this.assignedTo;
    }
    if (this.changedInstances != null) {
      data['changedInstances'] = this.changedInstances.map((e) => e.toDBDate()).toList();
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
