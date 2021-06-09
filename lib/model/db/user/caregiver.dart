import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';

import 'user.dart';

class Caregiver extends User {
  String? authenticationId;

  List<Currency>? currencies;
  List<Badge>? badges;
  List<ObjectId>? friends;

  Caregiver.fromAuthUser(AuthenticatedUser authUser) : this._(authenticationId: authUser.id, name: authUser.name, id: ObjectId());

  Caregiver._({ObjectId? id, String? name, List<String>? notificationIDs, this.badges, this.friends, this.authenticationId, this.currencies}) :
			  super(id: id, name: name, role: UserRole.caregiver, notificationIDs: notificationIDs);

  static Caregiver? fromJson(Json? json) {
    return json != null ? (Caregiver._(
	    id: json['_id'],
      friends: json['friends'] != null ? new List<ObjectId>.from(json['friends']) : [],
	    badges: json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
	    currencies: json['currencies'] != null ? (json['currencies'] as List).map((i) => Currency.fromJson(i)).toList() : [],
	    authenticationId: json['authenticationID'],
    )..assignFromJson(json)) : null;
  }

  Json toJson() {
    final Json data = super.toJson();
    if (this.authenticationId != null)
	    data['authenticationID'] = this.authenticationId;
    if (this.badges != null)
	    data['badges'] = this.badges!.map((v) => v.toJson()).toList();
    if (this.currencies != null)
	    data['currencies'] = this.currencies!.map((v) => v.toJson()).toList();
    if (this.friends != null)
      data['friends'] = this.friends;
    return data;
  }
}
