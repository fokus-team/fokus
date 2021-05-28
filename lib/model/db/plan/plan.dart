import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Plan {
  ObjectId? id;
  String? name;
  bool? active;

  PlanRepeatability? repeatability;
  List<Date>? changedInstances;
  TimeDate? createdAt;
  ObjectId? createdBy;

  List<ObjectId>? tasks;
  List<ObjectId>? instances;
  List<ObjectId>? assignedTo;

  Plan.fromPlanForm(PlanFormModel plan, ObjectId creator, PlanRepeatability repeatability, [ObjectId? id]) : this._(name: plan.name, id: id ?? ObjectId(),
		  active: plan.isActive, assignedTo: plan.children, createdAt: TimeDate.now(), createdBy: creator, repeatability: repeatability);

  Plan._({this.active, this.assignedTo, this.changedInstances, this.createdAt,
	  this.createdBy, this.id, this.instances, this.name, this.repeatability, this.tasks});

  static Plan? fromJson(Json? json) {
    return json != null ? Plan._(
      active: json['active'],
      assignedTo: json['assignedTo'] != null ? new List<ObjectId>.from(json['assignedTo']) : [],
      changedInstances: json['changedInstances'] != null ? (json['changedInstances'] as List).map((date) => Date.parseDBDate(date)!).toList() : [],
      createdAt: TimeDate.parseDBDate(json['createdAt']),
      createdBy: json['createdBy'],
      id: json['_id'],
      instances: json['instances'] != null ? new List<ObjectId>.from(json['instances']) : [],
      name: json['name'],
      repeatability: PlanRepeatability.fromJson(json['repeatability']),
      tasks: json['tasks'] != null ? new List<ObjectId>.from(json['tasks']) : [],
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (active != null)
      data['active'] = this.active;
    if (createdAt != null)
      data['createdAt'] = this.createdAt!.toDBDate();
    if (createdBy != null)
      data['createdBy'] = this.createdBy;
    if (id != null)
      data['_id'] = this.id;
    if (name != null)
      data['name'] = this.name;
    if (repeatability != null)
      data['repeatability'] = this.repeatability!.toJson();
    if (this.assignedTo != null)
      data['assignedTo'] = this.assignedTo;
    if (this.changedInstances != null)
      data['changedInstances'] = this.changedInstances!.map((e) => e.toDBDate()).toList();
    if (this.instances != null)
      data['instances'] = this.instances;
    if (this.tasks != null)
      data['tasks'] = this.tasks;
    return data;
  }
}
