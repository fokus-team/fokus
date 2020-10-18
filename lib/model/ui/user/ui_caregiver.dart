import 'package:bson/bson.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus_auth/fokus_auth.dart';

class UICaregiver extends UIUser {
	final AuthMethod authMethod;
	final List<ObjectId> friends;
	final List<UICurrency> currencies;
	final List<UIBadge> badges;

  UICaregiver({ObjectId id, String name, this.currencies, this.badges, this.authMethod, this.friends = const [], List<ObjectId> connections = const []}) :
			super(id, name, role: UserRole.caregiver, connections: connections);
  UICaregiver.fromDBModel(Caregiver caregiver, [this.authMethod]) :
		  friends = caregiver.friends,
			badges = caregiver.badges?.map((badge) => UIBadge.fromDBModel(badge))?.toList() ?? [],
		  currencies = [UICurrency(type: CurrencyType.diamond)]..addAll(caregiver.currencies?.map((currency) => UICurrency.fromDBModel(currency)) ?? []),
		  super.fromDBModel(caregiver);

	UICaregiver.from(UICaregiver original, {List<UICurrency> currencies, List<UIBadge> badges, String locale, String name, List<ObjectId> friends}) :
			currencies = currencies ?? original.currencies,
			badges = badges ?? original.badges,
			friends = friends ?? original.friends,
			authMethod = original.authMethod,
			super.from(original, locale: locale, name: name);

	@override
  List<Object> get props => super.props..addAll([friends, currencies, badges, authMethod]);
}
