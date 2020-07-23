import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/utils/app_locales.dart';

class UIPlanBase extends Equatable {
	final ObjectId id;
	final String name;
	final TranslateFunc description;

  UIPlanBase(this.id, this.name, this.description);

	@override
	List<Object> get props => [id, name, description];
}
