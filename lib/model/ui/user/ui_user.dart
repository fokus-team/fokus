import 'package:equatable/equatable.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';

import 'ui_caregiver.dart';
import 'ui_child.dart';

typedef ActiveUserFunction = UIUser Function();

class UIUser extends Equatable {
	final ObjectId id;
	final String name;
	final String locale;
	final int avatar;
	final UserRole role;
	final List<ObjectId> connections;

	UIUser(this.id, this.name, {this.locale, this.role, this.connections, this.avatar = -1});
	UIUser.fromDBModel(User user) : this(user.id, user.name, role: user.role, connections: user.connections, avatar: user.avatar, locale: user.locale);

	factory UIUser.typedFromDBModel(User user, [AuthMethod authMethod]) => user.role == UserRole.caregiver ? UICaregiver.fromDBModel(user, authMethod) : UIChild.fromDBModel(user);

	User toDBModel() => User(id: id, name: name, role: role, avatar: avatar);

	UIUser.from(UIUser original, {String locale, String name}) : this(
		original.id,
		name ?? original.name,
		locale: locale ?? original.locale,
		avatar: original.avatar,
		role: original.role,
		connections: original.connections
	);

	@override
  List<Object> get props => [id, name, avatar, role, locale, connections];

	@override
  String toString() {
    return 'UIUser{name: $name, role: $role}';
  }
}
