import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../services/model_helpers/plan_repeatability_service.dart';
import '../../../utils/definitions.dart';
import '../../ui/form/plan_form_model.dart';
import '../date/date.dart';
import '../date/time_date.dart';
import 'plan_repeatability.dart';

class Plan extends Equatable {
  final ObjectId? id;
  final String? name;
  final bool? active;

  final PlanRepeatability? repeatability;
  final List<Date>? changedInstances;
  final TimeDate? createdAt;
  final ObjectId? createdBy;

  final List<ObjectId>? tasks;
  final List<ObjectId>? instances;
  final List<ObjectId>? assignedTo;

  String? get description => repeatability != null ? PlanRepeatabilityService.buildPlanDescription(repeatability!) : null;

  Plan.fromPlanForm({required PlanFormModel plan, ObjectId? createdBy, PlanRepeatability? repeatability, List<ObjectId>? tasks, ObjectId? id}) : this._(
	  name: plan.name,
	  id: id ?? ObjectId(),
	  active: plan.isActive,
	  assignedTo: plan.children,
	  createdAt: TimeDate.now(),
	  createdBy: createdBy,
	  repeatability: repeatability,
	  tasks: tasks,
  );

  Plan._({this.active, this.assignedTo, this.changedInstances, this.createdAt,
	  this.createdBy, this.id, this.instances, this.name, this.repeatability, this.tasks});

  static Plan? fromJson(Json? json) {
    return json != null ? Plan._(
      active: json['active'],
      assignedTo: json['assignedTo'] != null ? List<ObjectId>.from(json['assignedTo']) : [],
      changedInstances: json['changedInstances'] != null ? (json['changedInstances'] as List).map((date) => Date.parseDBDate(date)!).toList() : [],
      createdAt: TimeDate.parseDBDate(json['createdAt']),
      createdBy: json['createdBy'],
      id: json['_id'],
      instances: json['instances'] != null ? List<ObjectId>.from(json['instances']) : [],
      name: json['name'],
      repeatability: json['repeatability'] != null ? PlanRepeatability.fromJson(json['repeatability']) : null,
      tasks: json['tasks'] != null ? List<ObjectId>.from(json['tasks']) : [],
    ) : null;
  }

  Plan copyWith({
	  ObjectId? id,
	  String? name,
	  bool? active,
	  List<ObjectId>? assignedTo,
	  ObjectId? createdBy,
  }) {
	  return Plan._(
		  id: id ?? this.id,
		  name: name ?? this.name,
		  active: active ?? this.active,
		  tasks: tasks ?? tasks,
		  assignedTo: assignedTo ?? (this.assignedTo != null ? List.from(this.assignedTo!) : null),
		  createdBy: createdBy ?? this.createdBy,
		  repeatability: repeatability,
		  changedInstances: changedInstances,
		  createdAt: createdAt,
		  instances: instances,
	  );
  }

  Json toJson() {
    final data = <String, dynamic>{};
    if (active != null)
      data['active'] = active;
    if (createdAt != null)
      data['createdAt'] = createdAt!.toDBDate();
    if (createdBy != null)
      data['createdBy'] = createdBy;
    if (id != null)
      data['_id'] = id;
    if (name != null)
      data['name'] = name;
    if (repeatability != null)
      data['repeatability'] = repeatability!.toJson();
    if (assignedTo != null)
      data['assignedTo'] = assignedTo;
    if (changedInstances != null)
      data['changedInstances'] = changedInstances!.map((e) => e.toDBDate()).toList();
    if (instances != null)
      data['instances'] = instances;
    if (tasks != null)
      data['tasks'] = tasks;
    return data;
  }

  @override
  List<Object?> get props => [active, createdBy, createdAt, id, name, repeatability, assignedTo, changedInstances, instances, tasks];
}
