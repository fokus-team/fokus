import 'package:bson/bson.dart';

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus_auth/fokus_auth.dart';

class UICaregiver extends UIUser {
	final AuthMethod? authMethod;
	final String? photoURL;
	final List<ObjectId>? friends;
	final List<Currency>? currencies;
	final List<UIBadge>? badges;

  UICaregiver({ObjectId? id, String? name, this.currencies, this.badges, this.authMethod, this.photoURL, this.friends = const [], List<ObjectId> connections = const []}) :
			super(id, name, role: UserRole.caregiver, connections: connections);
  UICaregiver.fromDBModel(Caregiver caregiver, [this.authMethod, this.photoURL]) :
		  friends = caregiver.friends,
			badges = caregiver.badges?.map((badge) => UIBadge.fromDBModel(badge)).toList() ?? [],
		  currencies = [Currency(type: CurrencyType.diamond)]..addAll(caregiver.currencies ?? []),
		  super.fromDBModel(caregiver);

	UICaregiver.from(UICaregiver original, {List<Currency>? currencies, List<UIBadge>? badges, String? locale, String? name, List<ObjectId>? friends, List<ObjectId>? connections}) :
			currencies = currencies ?? original.currencies,
			badges = badges ?? original.badges,
			friends = friends ?? original.friends,
			authMethod = original.authMethod,
			photoURL = original.photoURL,
			super.from(original, locale: locale, name: name, connections: connections);

	@override
  List<Object?> get props => super.props..addAll([friends, currencies, badges, authMethod, photoURL]);
}
