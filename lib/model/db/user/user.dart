import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import 'caregiver.dart';
import 'child.dart';
import 'user_role.dart';

class User extends Equatable {
  final ObjectId? id;
  final UserRole? role;
  final String? name;
  final String? locale;
  final List<String>? notificationIDs;

  final List<int>? accessCode;
  final int? avatar;
  final List<ObjectId>? connections;

  User({
	  this.id,
	  this.role,
	  this.name,
	  this.avatar = -1,
	  this.connections = const [],
	  this.notificationIDs = const [],
	  this.accessCode,
	  this.locale});

  User.copyFrom(User user, {String? locale, String? name, List<ObjectId>? connections}) : this(
	  id: user.id,
	  role: user.role,
	  name: name ?? user.name,
	  locale: locale ?? user.locale,
	  avatar: user.avatar,
	  accessCode: user.accessCode,
	  connections: connections ?? user.connections,
	  notificationIDs: user.notificationIDs,
  );

  @protected
  User.fromJson(Json json) : this(
	  id: json['_id'],
	  role: UserRole.values[json['role']],
	  name: json['name'],
    notificationIDs: json['notificationIDs'] != null ? List<String>.from(json['notificationIDs']) : [],
    accessCode: json['accessCode'] != null ? List<int>.from(json['accessCode']) : [],
    avatar: json['avatar'],
    locale: json['locale'],
    connections: json['connections'] != null ? List<ObjectId>.from(json['connections']) : [],
  );

  Json toJson() {
    final data = <String, dynamic>{};
    if (avatar != null)
      data['avatar'] = avatar;
    if (id != null)
      data['_id'] = id;
    if (name != null)
	    data['name'] = name;
    if (locale != null)
	    data['locale'] = locale;
    if (role != null)
	    data['role'] = role!.index;
    if (accessCode != null)
      data['accessCode'] = accessCode;
    if (notificationIDs != null)
	    data['notificationIDs'] = notificationIDs;
    if (connections != null)
      data['connections'] = connections;
    return data;
  }

  static User? typedFromJson(Json? json) {
  	if (json == null || json['role'] == null)
  		return null;
  	return json['role'] == UserRole.caregiver.index ? Caregiver.fromJson(json) : Child.fromJson(json);
  }

  @override
  List<Object?> get props => [id, avatar, name, locale, role, accessCode, notificationIDs, connections];
}
