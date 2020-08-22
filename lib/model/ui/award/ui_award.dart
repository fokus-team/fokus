import 'package:flutter/cupertino.dart';
import 'package:fokus/model/ui/ui_currency.dart';

class UIAward {
	Key key;
	String name;
	int limit;
	int pointValue;
	UICurrency pointCurrency;
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
