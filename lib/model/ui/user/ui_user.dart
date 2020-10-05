import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';

import 'ui_caregiver.dart';
import 'ui_child.dart';

typedef ActiveUserFunction = UIUser Function();

class UIUser extends Equatable {
	final ObjectId id;
	final String name;
	final int avatar;
	final UserRole role;
	final List<ObjectId> connections;

	UIUser(this.id, this.name, {this.role, this.connections, this.avatar = -1});
	UIUser.fromDBModel(User user) : this(user.id, user.name, role: user.role, connections: user.connections, avatar: user.avatar);

	factory UIUser.typedFromDBModel(User user) => user.role == UserRole.caregiver ? UICaregiver.fromDBModel(user) : UIChild.fromDBModel(user);

	User toDBModel() => User(id: id, name: name, role: role, avatar: avatar);

	@override
  List<Object> get props => [id, name, avatar, role, connections];

	@override
  String toString() {
    return 'UIUser{name: $name, role: $role}';
  }
}
