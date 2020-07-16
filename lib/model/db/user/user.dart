import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId id;
  final UserRole role;
  String name;

  List<int> accessCode;
  int avatar;
  List<ObjectId> connections;

  User({this.id, this.role});

  @protected
  void fromJson(Map<String, dynamic> json) {
    name = json['name'];
    accessCode = json['accessCode'] != null ? new List<int>.from(json['accessCode']) : [];
    avatar = json['avatar'];
    connections = json['connections'] != null ? new List<ObjectId>.from(json['connections']) : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['_id'] = this.id;
    data['name'] = this.name;
    data['role'] = this.role.index;
    if (this.accessCode != null) {
      data['accessCode'] = this.accessCode;
    }
    if (this.connections != null) {
      data['connections'] = this.connections;
    }
    return data;
  }

  static User typedFromJson(Map<String, dynamic> json) {
  	var rawRole = json['role'];
  	if (rawRole == null)
  		return null;
  	return rawRole == UserRole.caregiver.index ? Caregiver.fromJson(json) : Child.fromJson(json);
  }
}
