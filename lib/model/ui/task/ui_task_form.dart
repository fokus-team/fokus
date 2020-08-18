import 'package:flutter/material.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';

class UITask {
	Key key;
	String name;
	String description;
	int pointsValue;
	UIPlanCurrency pointCurrency;
	int timer;
	bool optional;

	UITask({
		@required this.key, 
		this.name,
		this.description,
		this.pointsValue,
		this.pointCurrency,
		this.timer = 0,
		this.optional = false
	});

	void copy(UITask task) {
		key = task.key;
		name = task.name;
		description = task.description;
		pointsValue = task.pointsValue;
		pointCurrency = task.pointCurrency;
		timer = task.timer;
		optional = task.optional;
	}

}
