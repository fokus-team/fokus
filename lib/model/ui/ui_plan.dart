import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/utils/app_locales.dart';

class UIPlan extends Equatable {
	final ObjectId id;
	final String name;
	final TranslateFunc description;
	final int taskCount;

  UIPlan(this.id, this.name, this.taskCount, [this.description]);
	UIPlan.fromDBModel(Plan plan, [TranslateFunc description]) : this(plan.id, plan.name, plan.tasks.length, description);

  @override
  List<Object> get props => [id, name, taskCount, description];

  String print(BuildContext context) {
    return 'UIPlan{name: $name, repeatabilityDescription: ${description(context)}, taskCount: $taskCount}';
  }
}
