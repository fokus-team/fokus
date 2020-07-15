import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIPlan extends Equatable {
	final ObjectId id;
	final String name;
	final String repeatabilityDescription;
	final int taskCount;

  UIPlan(this.id, this.name, this.taskCount, [this.repeatabilityDescription]);

  @override
  List<Object> get props => [id, name, taskCount, repeatabilityDescription];
}
