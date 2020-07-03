import 'package:fokus/data/model/date/date.dart';
import 'package:fokus/data/model/date/time_date.dart';
import 'package:fokus/data/model/duration.dart';

class PlanInstance {
  String assignedTo;
  Date date;
  Duration<TimeDate> duration;
  String ID;
  List<String> instances;
  String planID;
  List<InstanceTask> tasks;

  PlanInstance({this.assignedTo, this.date, this.duration, this.ID, this.instances, this.planID, this.tasks});

  factory PlanInstance.fromJson(Map<String, dynamic> json) {
    return PlanInstance(
      assignedTo: json['assignedTo'],
      date: Date.parseDBString(json['date']),
      duration: json['duration'] != null ? Duration.fromJson(json['duration']) : null,
      ID: json['_id'],
      instances: json['instances'] != null ? new List<String>.from(json['instances']) : null,
      planID: json['planID'],
      tasks: json['tasks'] != null ? (json['tasks'] as List).map((i) => InstanceTask.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assignedTo'] = this.assignedTo;
    data['date'] = this.date.toDBString();
    data['_id'] = this.ID;
    data['planID'] = this.planID;
    if (this.duration != null) {
      data['duration'] = this.duration.toJson();
    }
    if (this.instances != null) {
      data['instances'] = this.instances;
    }
    if (this.tasks != null) {
      data['tasks'] = this.tasks.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class InstanceTask {
  String createdBy;
  String taskID;

  InstanceTask({this.createdBy, this.taskID});

  factory InstanceTask.fromJson(Map<String, dynamic> json) {
    return InstanceTask(
      createdBy: json['createdBy'],
      taskID: json['taskID'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['taskID'] = this.taskID;
    return data;
  }
}
