import 'package:fokus/model/auth_user.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'user.dart';

class Caregiver extends User {
  final String email;
  String authenticationId;

  List<Currency> currencies;
  List<Badge> badges;
  List<ObjectId> friends;

  Caregiver.fromAuthUser(AuthenticatedUser authUser) : this._(authenticationId: authUser.id, email: authUser.email, name: authUser.name);

  Caregiver._({ObjectId id, String name, this.badges, this.email, this.friends, this.authenticationId, this.currencies}) : super(id: id, name: name, role: UserRole.caregiver);

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return json != null ? (Caregiver._(
	    id: json['_id'],
      email: json['email'],
      friends: json['friends'] != null ? new List<ObjectId>.from(json['friends']) : [],
	    badges: json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
	    currencies: json['currencies'] != null ? (json['currencies'] as List).map((i) => Currency.fromJson(i)).toList() : [],
	    authenticationId: json['authenticationID'],
    )..fromJson(json)) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.email != null)
	    data['email'] = this.email;
    if (this.authenticationId != null)
	    data['authenticationID'] = this.authenticationId;
    if (this.badges != null)
	    data['badges'] = this.badges.map((v) => v.toJson()).toList();
    if (this.currencies != null)
	    data['currencies'] = this.currencies.map((v) => v.toJson()).toList();
    if (this.friends != null)
      data['friends'] = this.friends;
    return data;
  }
}
