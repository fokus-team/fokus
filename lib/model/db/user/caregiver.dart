import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'user.dart';

class Caregiver extends User {
  final String email;
  String password;

  List<Currency> currencies;
  List<Badge> badges;
  List<ObjectId> friends;

  Caregiver({ObjectId id, this.badges, this.email, this.friends, this.password, this.currencies}) : super(id: id, role: UserRole.caregiver);

  factory Caregiver.fromJson(Map<String, dynamic> json) {
    return json != null ? (Caregiver(
	    id: json['_id'],
      email: json['email'],
      friends: json['friends'] != null ? new List<ObjectId>.from(json['friends']) : [],
	    badges: json['badges'] != null ? (json['badges'] as List).map((i) => Badge.fromJson(i)).toList() : [],
	    currencies: json['currencies'] != null ? (json['currencies'] as List).map((i) => Currency.fromJson(i)).toList() : [],
      password: json['password'],
    )..fromJson(json)) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.email != null)
	    data['email'] = this.email;
    if (this.password != null)
	    data['password'] = this.password;
    if (this.badges != null)
	    data['badges'] = this.badges.map((v) => v.toJson()).toList();
    if (this.currencies != null)
	    data['currencies'] = this.currencies.map((v) => v.toJson()).toList();
    if (this.friends != null)
      data['friends'] = this.friends;
    return data;
  }
}
