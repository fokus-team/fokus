import 'package:fokus/data/model/user/user_type.dart';
import 'package:meta/meta.dart';
import 'package:mongo_dart/mongo_dart.dart';

class User {
// ignore: non_constant_identifier_names
  final ObjectId id;
  final UserType type;
  String name;

  List<int> accessCode;
  int avatar;
  List<String> connections;

  User({this.id, this.type});

  @protected
  void fromJson(Map<String, dynamic> json) {
    name = json['name'];
    accessCode = json['accessCode'] != null ? new List<int>.from(json['accessCode']) : null;
    avatar = json['avatar'];
    connections = json['connections'] != null ? new List<String>.from(json['connections']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['_id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type.index;
    if (this.accessCode != null) {
      data['accessCode'] = this.accessCode;
    }
    if (this.connections != null) {
      data['connections'] = this.connections;
    }
    return data;
  }
}
