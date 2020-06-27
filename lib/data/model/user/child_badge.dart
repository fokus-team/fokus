class ChildBadge {
  String comment;
  String date;
  int icon;
  int level;
  int maxLevel;
  String name;

  ChildBadge({this.comment, this.date, this.icon, this.level, this.maxLevel, this.name});

  factory ChildBadge.fromJson(Map<String, dynamic> json) {
    return ChildBadge(
      comment: json['comment'],
      date: json['date'],
      icon: json['icon'],
      level: json['level'],
      maxLevel: json['maxLevel'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['comment'] = this.comment;
    data['date'] = this.date;
    data['icon'] = this.icon;
    data['level'] = this.level;
    data['maxLevel'] = this.maxLevel;
    data['name'] = this.name;
    return data;
  }
}
