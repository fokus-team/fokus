import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../../currency_type.dart';
import '../gamification/badge.dart';
import '../gamification/currency.dart';
import 'user.dart';
import 'user_role.dart';

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
			  currencies = currencies..insert(0, _defaultCurrency),
			  super(id: id, name: name, role: UserRole.caregiver, notificationIDs: notificationIDs);

  Caregiver.fromJson(Json json) :
      friends = json['friends'] != null ? List<ObjectId>.from(json['friends']) : [],
	    badges = json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
	    currencies = (json['currencies'] != null ? (json['currencies'] as List).map((i) => Currency.fromJson(i)).toList() : [])..insert(0, _defaultCurrency),
	    authenticationId = json['authenticationID'],
      super.fromJson(json);

  Caregiver.copyFrom(Caregiver user, {List<Currency>? currencies, List<Badge>? badges, String? locale, String? name, List<ObjectId>? friends, List<ObjectId>? connections}) : 
		  currencies = (currencies?..insert(0, _defaultCurrency)) ?? user.currencies,
		  badges = badges ?? user.badges,
		  friends = friends ?? user.friends,
		  authenticationId = user.authenticationId,
		  super.copyFrom(user, locale: locale, name: name, connections: connections);

  @override
  Json toJson() {
    final data = super.toJson();
    if (authenticationId != null)
	    data['authenticationID'] = authenticationId;
    if (badges != null)
	    data['badges'] = badges!.map((v) => v.toJson()).toList();
    if (currencies != null)
	    data['currencies'] = currencies!.where((c) => c.type != CurrencyType.diamond).map((v) => v.toJson()).toList();
    if (friends != null)
      data['friends'] = friends;
    return data;
  }

  @override
  List<Object?> get props => super.props..addAll([badges, authenticationId, currencies, friends]);
}
