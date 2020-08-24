import 'package:fokus/model/ui/award/ui_points.dart';

class UIAward {
	String name;
	int limit;
	UIPoints points;
	int icon;

	UIAward({
		this.name,
		this.limit = 0,
		this.points,
		this.icon = 0
	});

}
