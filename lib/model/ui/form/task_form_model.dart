import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:mongo_dart/mongo_dart.dart';


// ignore: must_be_immutable
class TaskFormModel extends Equatable {
	ObjectId id;
	Key key;
	String title;
	String description;
	int pointsValue;
	UICurrency pointCurrency;
	int timer;
	bool optional;

	TaskFormModel({
		@required this.key, 
		this.title,
		this.description,
		this.pointsValue,
		this.pointCurrency,
		this.id,
		this.timer = 0,
		this.optional = false,
	});

	TaskFormModel.fromDBModel(Task task) : this(id: task.id, key: ValueKey(task.id), title: task.name,
			description: task.description, timer: task.timer ?? 0, optional: task.optional ?? false, pointsValue: task.points?.quantity,
			pointCurrency: task.points != null ? UICurrency.fromDBModel(task.points) : UICurrency(type: CurrencyType.diamond));

	TaskFormModel.from(TaskFormModel task) : this(id: task.id, key: task.key, title: task.title, description: task.description,
			pointsValue: task.pointsValue, pointCurrency: UICurrency.from(task.pointCurrency), timer: task.timer, optional: task.optional);

	@override
	List<Object> get props => [id, title, description, pointsValue, pointCurrency, timer, optional];

	void copy(TaskFormModel task) {
		key = task.key;
		title = task.title;
		description = task.description;
		pointsValue = task.pointsValue;
		pointCurrency = task.pointCurrency;
		timer = task.timer;
		optional = task.optional;
		id = task.id;
	}
}
