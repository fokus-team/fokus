class Badge {
  int icon;
  int maxLevel;
  String name;

  Badge({this.icon, this.maxLevel, this.name});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      icon: json['icon'],
      maxLevel: json['maxLevel'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['icon'] = this.icon;
    data['maxLevel'] = this.maxLevel;
    data['name'] = this.name;
    return data;
  }
}
