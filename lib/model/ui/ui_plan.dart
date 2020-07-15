import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIPlan extends Equatable {
	final ObjectId id;
	final String name;
	final String repeatabilityDescription;
	final int taskCount;

  UIPlan(this.id, this.name, this.taskCount, [this.repeatabilityDescription]);
	UIPlan.fromDBModel(Plan plan) : this(plan.id, plan.name, plan.tasks.length);

  @override
  List<Object> get props => [id, name, taskCount, repeatabilityDescription];
}
