import 'package:fokus/model/ui/ui_currency.dart';

class UIAward {
	String name;
	int limit;
	int pointValue;
	UICurrency pointCurrency;
	int icon;

	UIAward({
		this.name,
		this.limit = 0,
		this.pointValue,
		this.pointCurrency,
		this.icon = 0
	});

}
