import 'package:fokus/model/db/gamification/badge.dart';

enum UIBadgeMaxLevel { one, three, five }

extension UIBadgeMaxLevelExtension on UIBadgeMaxLevel {
  int get value {
    switch (this) {
      case UIBadgeMaxLevel.one:
        return 1;
      case UIBadgeMaxLevel.three:
        return 3;
      case UIBadgeMaxLevel.five:
        return 5;
      default:
        return null;
    }
  }
}

class UIBadge {
	String name;
	String description;
	UIBadgeMaxLevel maxLevel;
	int icon;
	DateTime date;

	UIBadge({
		this.name,
		this.description,
		this.maxLevel = UIBadgeMaxLevel.one,
		this.icon = 0,
		this.date
	});
	UIBadge.fromDBModel(Badge badge) : this(
		name: badge.name,
		description:
		badge.description,
		icon: badge.icon,
		maxLevel: UIBadgeMaxLevel.values.firstWhere((level) => level.value == badge.maxLevel, orElse: () => UIBadgeMaxLevel.one)
	);

}
