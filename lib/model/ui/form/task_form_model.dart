import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../currency_type.dart';
import '../../db/gamification/currency.dart';
import '../../db/plan/task.dart';


// ignore: must_be_immutable
class TaskFormModel extends Equatable {
	ObjectId? id;
	Key key;
	String? title;
	String? description;
	int? pointsValue;
	Currency? pointCurrency;
	int? timer;
	bool? optional;
	List<String>? subtasks;

	TaskFormModel({
		required this.key,
		this.title,
		this.description,
		this.pointsValue,
		this.pointCurrency,
		this.id,
		this.timer = 0,
		this.optional = false,
		this.subtasks
	});

	TaskFormModel.fromDBModel(Task task) : this(id: task.id, key: ValueKey(task.id), title: task.name,
			description: task.description, timer: task.timer ?? 0, optional: task.optional ?? false, subtasks: task.subtasks, pointsValue: task.points?.quantity,
			pointCurrency: task.points ?? Currency(type: CurrencyType.diamond));

	TaskFormModel.from(TaskFormModel task) : this(id: task.id, key: task.key, title: task.title, description: task.description,
			pointsValue: task.pointsValue, pointCurrency: task.pointCurrency, timer: task.timer, optional: task.optional, subtasks: task.subtasks);

	@override
	List<Object?> get props => [id, title, description, pointsValue, pointCurrency, timer, optional, subtasks];

	void copy(TaskFormModel task) {
		key = task.key;
		title = task.title;
		description = task.description;
		pointsValue = task.pointsValue;
		pointCurrency = task.pointCurrency;
		timer = task.timer;
		optional = task.optional;
		id = task.id;
		subtasks = task.subtasks;
	}
}
