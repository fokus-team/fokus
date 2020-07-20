import 'package:bson/bson.dart';
import 'package:fokus/model/db/user/user_role.dart';

import 'package:fokus/model/ui/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';

class UICaregiver extends UIUser {
	final List<ObjectId> friends;

  UICaregiver(ObjectId id, String name, {this.friends = const []}) : super(id, name, role: UserRole.caregiver);
  UICaregiver.fromDBModel(Caregiver caregiver) : this(caregiver.id, caregiver.name, friends: caregiver.friends);

	@override
  List<Object> get props => super.props..addAll([friends]);
}
