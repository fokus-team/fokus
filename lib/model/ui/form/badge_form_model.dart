import 'package:equatable/equatable.dart';
import '../../db/gamification/badge.dart';

// ignore: must_be_immutable
class BadgeFormModel extends Equatable {
	String? name;
	String? description;
	int? icon = 0;

	BadgeFormModel();
	BadgeFormModel.fromDBModel(Badge badge) : name = badge.name, description = badge.description, icon = badge.icon;

	@override
	List<Object?> get props => [name, description, icon];
}
