class Badge {
  int icon;
  int maxLevel;
  String name;
  String description;

  Badge({this.icon, this.maxLevel, this.name, this.description});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return json != null ? Badge(
      icon: json['icon'],
      maxLevel: json['maxLevel'],
      name: json['name'],
			description: json['description']
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['maxLevel'] = this.maxLevel;
    data['name'] = this.name;
		data['description'] = this.description;
    return data;
  }
}
