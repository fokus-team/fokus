import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/duration.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanInstance {
	ObjectId id;
	ObjectId planID;
	ObjectId assignedTo;

  Date date;
  bool active;
  Duration<TimeDate> duration;
  List<ObjectId> instances;
  List<PlanInstanceTask> tasks;

  PlanInstance({this.id, this.instances, this.planID, this.assignedTo, this.date, this.active, this.duration, this.tasks});

  factory PlanInstance.fromJson(Map<String, dynamic> json) {
    return PlanInstance(
	    id: json['_id'],
	    active: json['active'],
	    planID: json['planID'],
      assignedTo: json['assignedTo'],
      date: Date.parseDBString(json['date']),
      duration: json['duration'] != null ? Duration.fromJson(json['duration']) : null,
      instances: json['instances'] != null ? new List<ObjectId>.from(json['instances']) : [],
      tasks: json['tasks'] != null ? (json['tasks'] as List).map((i) => PlanInstanceTask.fromJson(i)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['planID'] = this.planID;
    data['active'] = this.active;
    data['assignedTo'] = this.assignedTo;
    data['date'] = this.date.toDBString();
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

class PlanInstanceTask {
	ObjectId createdBy;
  ObjectId taskInstanceID;

  PlanInstanceTask({this.createdBy, this.taskInstanceID});

  factory PlanInstanceTask.fromJson(Map<String, dynamic> json) {
    return PlanInstanceTask(
      createdBy: json['createdBy'],
      taskInstanceID: json['taskID'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['taskID'] = this.taskInstanceID;
    return data;
  }
}
