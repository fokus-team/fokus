import 'package:flutter/material.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';

class UITaskForm {
	Key key;
	String title;
	String description;
	int pointsValue;
	UIPlanCurrency pointCurrency;
	int timer;
	bool optional;

	UITaskForm({
		@required this.key, 
		this.title,
		this.description,
		this.pointsValue,
		this.pointCurrency,
		this.timer = 0,
		this.optional = false
	});

	void copy(UITaskForm task) {
		key = task.key;
		title = task.title;
		description = task.description;
		pointsValue = task.pointsValue;
		pointCurrency = task.pointCurrency;
		timer = task.timer;
		optional = task.optional;
	}

}
