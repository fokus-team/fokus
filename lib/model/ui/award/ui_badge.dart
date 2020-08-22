
enum UIBadgeLevel { one, three, five }

class UIBadge {
	String name;
	String description;
	UIBadgeLevel level;
	int icon;

	UIBadge({
		this.name,
		this.description,
		this.level = UIBadgeLevel.one,
		this.icon = 0
	});

}
