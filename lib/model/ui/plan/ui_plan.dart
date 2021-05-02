import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/services/app_locales.dart';

import 'ui_plan_base.dart';

class UIPlan extends UIPlanBase {
  final int? taskCount;
  final bool? isActive;
  final List<ObjectId>? assignedTo;
  final ObjectId? createdBy;

  UIPlan(
    ObjectId? id,
    String? name,
    this.isActive,
    this.taskCount,
    this.assignedTo,
    TranslateFunc? description,
    this.createdBy,
  ) : super(id, name, description);

  UIPlan.fromDBModel(Plan plan, [TranslateFunc? description])
      : this(
          plan.id,
          plan.name,
          plan.active,
          plan.tasks?.length,
          plan.assignedTo,
          description,
          plan.createdBy,
        );

  UIPlan copyWith({
    ObjectId? id,
    String? name,
    bool? isActive,
    int? taskCount,
    List<ObjectId>? assignedTo,
    TranslateFunc? description,
    ObjectId? createdBy,
  }) {
    return UIPlan(
      id ?? this.id,
      name ?? this.name,
      isActive ?? this.isActive,
      taskCount ?? this.taskCount,
      assignedTo ?? (this.assignedTo != null ? List.from(this.assignedTo!) : null),
      description ?? this.description,
      createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => super.props..addAll([taskCount, assignedTo, isActive, createdBy]);

  @override
  String toString() {
    return 'UIPlan{name: $name, taskCount: $taskCount, isActive: $isActive}';
  }
}
