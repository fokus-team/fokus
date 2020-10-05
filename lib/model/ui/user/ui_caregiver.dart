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
	final List<UIBadge> badges;

  UICaregiver(ObjectId id, String name, {this.currencies, this.badges, this.friends = const []}) : super(id, name, role: UserRole.caregiver);
  UICaregiver.fromDBModel(Caregiver caregiver) :
		  friends = caregiver.friends,
			badges = caregiver.badges?.map((badge) => UIBadge.fromDBModel(badge))?.toList() ?? [],
		  currencies = [UICurrency(type: CurrencyType.diamond)]..addAll(caregiver.currencies?.map((currency) => UICurrency.fromDBModel(currency)) ?? []),
		  super.fromDBModel(caregiver);

	UICaregiver copyWith({List<UICurrency> currencies, List<UIBadge> badges}) {
		return UICaregiver(
			id,
			name,
			currencies: currencies ?? this.currencies,
			badges: badges ?? this.badges,
			friends: friends
		);
	}

	@override
  List<Object> get props => super.props..addAll([friends, currencies, connections, badges]);
}
