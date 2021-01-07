import 'package:fokus/model/db/date/date.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum AppFormType { create, edit, copy }

class AppFormArgument {
	final AppFormType type;
	final ObjectId id;
	final Date date;

	AppFormArgument({this.type, this.id, this.date});
}
