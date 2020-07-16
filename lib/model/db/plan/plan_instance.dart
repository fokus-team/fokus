import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/duration.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanInstance {
	ObjectId id;
	ObjectId planID;
	ObjectId assignedTo;

  Date date;
  Duration<TimeDate> duration;
  List<ObjectId> instances;
  List<PlanInstanceTask> tasks;

  PlanInstance({this.assignedTo, this.date, this.duration, this.id, this.instances, this.planID, this.tasks});

  factory PlanInstance.fromJson(Map<String, dynamic> json) {
    return PlanInstance(
      assignedTo: json['assignedTo'],
      date: Date.parseDBString(json['date']),
      duration: json['duration'] != null ? Duration.fromJson(json['duration']) : null,
	    id: json['_id'],
      instances: json['instances'] != null ? new List<ObjectId>.from(json['instances']) : null,
      planID: json['planID'],
      tasks: json['tasks'] != null ? (json['tasks'] as List).map((i) => PlanInstanceTask.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assignedTo'] = this.assignedTo;
    data['date'] = this.date.toDBString();
    data['_id'] = this.id;
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
