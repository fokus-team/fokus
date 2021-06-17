import 'package:equatable/equatable.dart';

import '../../../utils/definitions.dart';
import '../../ui/form/badge_form_model.dart';

class Badge extends Equatable {
  final String? name;
  final String? description;
  final int? icon;

  Badge({this.name, this.description, this.icon = 0});
	Badge.fromBadgeForm(BadgeFormModel badge) : this(name: badge.name, description: badge.description, icon: badge.icon);

  Badge.fromJson(Json json) : this(name: json['name'], icon: json['icon'], description: json['description']);

  Json toJson() {
    final data = <String, dynamic>{};
    if (icon != null)
      data['icon'] = icon;
    if (name != null)
      data['name'] = name;
		if (description != null)
      data['description'] = description;
    return data;
  }

  @override
  List<Object?> get props => [name, description, icon];
}
