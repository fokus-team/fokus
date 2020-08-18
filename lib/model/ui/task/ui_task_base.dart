import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UITaskBase extends Equatable {
	final ObjectId id;
	final bool optional;

  UITaskBase(this.id, this.optional);


  @override
  List<Object> get props =>[id, optional];

}
