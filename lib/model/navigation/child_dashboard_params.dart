import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildDashboardParams {
	final UIChild child;
	final int tab;
	final ObjectId id;

  ChildDashboardParams({this.child, this.tab, this.id});
}
