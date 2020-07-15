import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIUser extends Equatable {
	final ObjectId id;
	final String name;
	final int avatar;
	final UserRole role;

	UIUser(this.id, this.name, {this.role, this.avatar = -1});
	UIUser.fromDBModel(User user) : this(user.id, user.name, role: user.role, avatar: user.avatar);

	@override
  List<Object> get props => [id, name, avatar];
}
