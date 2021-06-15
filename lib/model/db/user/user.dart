import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

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
    notificationIDs: json['notificationIDs'] != null ? new List<String>.from(json['notificationIDs']) : [],
    accessCode: json['accessCode'] != null ? new List<int>.from(json['accessCode']) : [],
    avatar: json['avatar'],
    locale: json['locale'],
    connections: json['connections'] != null ? new List<ObjectId>.from(json['connections']) : [],
  );

  Json toJson() {
    final data = Json();
    if (this.avatar != null)
      data['avatar'] = this.avatar;
    if (this.id != null)
      data['_id'] = this.id;
    if (this.name != null)
	    data['name'] = this.name;
    if (this.locale != null)
	    data['locale'] = this.locale;
    if (this.role != null)
	    data['role'] = this.role!.index;
    if (this.accessCode != null)
      data['accessCode'] = this.accessCode;
    if (this.notificationIDs != null)
	    data['notificationIDs'] = this.notificationIDs;
    if (this.connections != null)
      data['connections'] = this.connections;
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
