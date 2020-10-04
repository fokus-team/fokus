import 'package:bson/bson.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';

class UICaregiver extends UIUser {
	final List<ObjectId> friends;
	final List<UICurrency> currencies;
	final List<ObjectId> connections;
	final List<UIBadge> badges;

  UICaregiver({ObjectId id, String name, this.currencies, this.badges, this.connections, this.friends = const []}) : super(id, name, role: UserRole.caregiver);
  UICaregiver.fromDBModel(Caregiver caregiver) :
		  friends = caregiver.friends,
			badges = caregiver.badges?.map((badge) => UIBadge.fromDBModel(badge))?.toList() ?? [],
		  currencies = [UICurrency(type: CurrencyType.diamond)]..addAll(caregiver.currencies?.map((currency) => UICurrency.fromDBModel(currency)) ?? []),
      connections = caregiver.connections,
		  super.fromDBModel(caregiver);

	UICaregiver.from(UICaregiver original, {List<UICurrency> currencies, String locale}) :
			currencies = currencies ?? original.currencies,
			badges = original.badges,
			connections = original.connections,
			friends = original.friends,
			super.from(original, locale: locale);

	@override
  List<Object> get props => super.props..addAll([friends, currencies, connections, badges]);
}
