import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId id;
  final UserRole role;
  String name;
  String locale;
  List<String> notificationIDs;

  List<int> accessCode;
  int avatar;
  List<ObjectId> connections;

  User({this.id, this.role, this.name, this.avatar, this.connections, this.notificationIDs, this.accessCode});

  @protected
  void fromJson(Map<String, dynamic> json) {
    name = json['name'];
    notificationIDs = json['notificationIDs'] != null ? new List<String>.from(json['notificationIDs']) : [];
    accessCode = json['accessCode'] != null ? new List<int>.from(json['accessCode']) : [];
    avatar = json['avatar'];
    locale = json['locale'];
    connections = json['connections'] != null ? new List<ObjectId>.from(json['connections']) : [];
    connections = json['connections'] != null ? new List<ObjectId>.from(json['connections']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.avatar != null)
      data['avatar'] = this.avatar;
    if (this.id != null)
      data['_id'] = this.id;
    if (this.name != null)
	    data['name'] = this.name;
    if (this.locale != null)
	    data['locale'] = this.locale;
    if (this.role != null)
	    data['role'] = this.role.index;
    if (this.accessCode != null)
      data['accessCode'] = this.accessCode;
    if (this.notificationIDs != null)
	    data['notificationIDs'] = this.notificationIDs;
    if (this.connections != null)
      data['connections'] = this.connections;
    return data;
  }

  factory User.typedFromJson(Map<String, dynamic> json) {
  	if (json == null || json['role'] == null)
  		return null;
  	return json['role'] == UserRole.caregiver.index ? Caregiver.fromJson(json) : Child.fromJson(json);
  }
}
