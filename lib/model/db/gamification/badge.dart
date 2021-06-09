import 'package:equatable/equatable.dart';
import 'package:fokus/model/ui/form/badge_form_model.dart';
import 'package:fokus/utils/definitions.dart';

class Badge extends Equatable {
  final String? name;
  final String? description;
  final int? icon;

  Badge({this.name, this.description, this.icon});
	Badge.fromBadgeForm(BadgeFormModel badge) : this(name: badge.name, description: badge.description, icon: badge.icon);

  Badge.fromJson(Json json) : this(name: json['name'], icon: json['icon'], description: json['description']);

  Json toJson() {
    final Json data = new Json();
    if (this.icon != null)
      data['icon'] = this.icon;
    if (this.name != null)
      data['name'] = this.name;
		if (this.description != null)
      data['description'] = this.description;
    return data;
  }

  @override
  List<Object?> get props => [name, description, icon];
}
