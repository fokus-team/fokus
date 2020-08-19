import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UITaskBase extends Equatable {
	final ObjectId id;
	final String name;
	final bool optional;
	final String description;

  UITaskBase(this.id, this.name, this.optional, this.description);


  @override
  List<Object> get props =>[id, name, optional, description];

}
