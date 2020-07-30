import 'package:bson/bson.dart';
import 'package:fokus/model/db/user/user_role.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/db/user/caregiver.dart';

class UICaregiver extends UIUser {
	final List<ObjectId> friends;

  UICaregiver(ObjectId id, String name, {this.friends = const []}) : super(id, name, role: UserRole.caregiver);
  UICaregiver.fromDBModel(Caregiver caregiver) : friends = caregiver.friends, super.fromDBModel(caregiver);

	@override
  List<Object> get props => super.props..addAll([friends]);
}
