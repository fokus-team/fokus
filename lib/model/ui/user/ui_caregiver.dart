import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/ui_currency.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';

class UICaregiver extends UIUser {
	final List<ObjectId> friends;
	final List<UICurrency> currencies;

  UICaregiver(ObjectId id, String name, {this.currencies, this.friends = const []}) : super(id, name, role: UserRole.caregiver);
  UICaregiver.fromDBModel(Caregiver caregiver) :
		  friends = caregiver.friends,
		  currencies = [UICurrency(type: CurrencyType.diamond)]..addAll(caregiver.currencies.map((currency) => UICurrency.fromDBModel(currency))),
		  super.fromDBModel(caregiver);

	@override
  List<Object> get props => super.props..addAll([friends]);
}
