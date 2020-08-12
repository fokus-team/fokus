import 'package:flutter/cupertino.dart';
import 'package:fokus/model/ui/plan/ui_plan_currency.dart';

class UIAward {
	Key key;
	String name;
	int limit;
	int pointValue;
	UIPlanCurrency pointCurrency;
	int icon;

	UIAward({
		@required this.key,
		this.name,
		this.limit = 0,
		this.pointValue,
		this.pointCurrency,
		this.icon = 0
	});

}
