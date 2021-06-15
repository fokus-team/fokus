import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';

import 'user.dart';

final _defaultCurrency = Currency(type: CurrencyType.diamond);

class Caregiver extends User {
  final String? authenticationId;

  final List<Currency>? currencies;
  final List<Badge>? badges;
  final List<ObjectId>? friends;

  Caregiver.fromAuthUser(AuthenticatedUser authUser) : this._(authenticationId: authUser.id, name: authUser.name, id: ObjectId());

  Caregiver._({
	  ObjectId? id, 
	  String? name, 
	  List<String>? notificationIDs, 
	  this.badges = const [], 
	  this.friends = const [], 
	  this.authenticationId, 
	  List<Currency> currencies = const [],
  }) :
			  currencies = currencies..add(_defaultCurrency), 
			  super(id: id, name: name, role: UserRole.caregiver, notificationIDs: notificationIDs);

  Caregiver.fromJson(Json json) :
      friends = json['friends'] != null ? new List<ObjectId>.from(json['friends']) : [],
	    badges = json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
	    currencies = (json['currencies'] != null ? (json['currencies'] as List).map((i) => Currency.fromJson(i)).toList() : [])..add(_defaultCurrency),
	    authenticationId = json['authenticationID'],
      super.fromJson(json);

  Caregiver.copyFrom(Caregiver user, {List<Currency>? currencies, List<Badge>? badges, String? locale, String? name, List<ObjectId>? friends, List<ObjectId>? connections}) : 
		  currencies = (currencies?..add(_defaultCurrency)) ?? user.currencies,
		  badges = badges ?? user.badges,
		  friends = friends ?? user.friends,
		  authenticationId = user.authenticationId,
		  super.copyFrom(user, locale: locale, name: name, connections: connections);

  Json toJson() {
    final Json data = super.toJson();
    if (this.authenticationId != null)
	    data['authenticationID'] = this.authenticationId;
    if (this.badges != null)
	    data['badges'] = this.badges!.map((v) => v.toJson()).toList();
    if (this.currencies != null)
	    data['currencies'] = this.currencies!.where((c) => c.type != CurrencyType.diamond).map((v) => v.toJson()).toList();
    if (this.friends != null)
      data['friends'] = this.friends;
    return data;
  }

  @override
  List<Object?> get props => super.props..addAll([badges, authenticationId, currencies, friends]);
}
