// @dart = 2.10
import 'package:fokus/model/ui/form/badge_form_model.dart';

class Badge {
  String name;
  String description;
  int icon;

  Badge({this.name, this.description, this.icon});
	Badge.fromBadgeForm(BadgeFormModel badge) : this(name: badge.name, description: badge.description, icon: badge.icon);

  factory Badge.fromJson(Map<String, dynamic> json) {
    return json != null ? Badge(
      icon: json['icon'],
      name: json['name'],
			description: json['description']
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.icon != null)
      data['icon'] = this.icon;
    if (this.name != null)
      data['name'] = this.name;
		if (this.description != null)
      data['description'] = this.description;
    return data;
  }
}
