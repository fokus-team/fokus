import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';

import 'points.dart';

class Reward extends Equatable {
  final ObjectId? id;
  final int? icon;
  final int? limit;
  final String? name;
  final Points? cost;
  final ObjectId? createdBy;

  Reward({this.createdBy, ObjectId? id, this.icon = 0, this.limit = 0, this.name, this.cost}) : id = id ?? ObjectId();

  Reward.fromJson(Json json) : this(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      cost: json['cost'] != null ? Points.fromJson(json['cost']) : null,
    );

  Reward copyWith({String? name, int? limit, Points? cost, int? icon, ObjectId? createdBy, ObjectId? id}) {
	  return Reward(
		  name: name ?? this.name,
		  limit: limit ?? this.limit,
		  cost: cost ?? this.cost,
		  icon: icon ?? this.icon,
		  id: id ?? this.id,
		  createdBy: createdBy ?? this.createdBy,
	  );
  }

  Json toJson() {
    final Json data = new Json();
    if (this.createdBy != null)
	    data['createdBy'] = this.createdBy;
    if (this.id != null)
	    data['_id'] = this.id;
    if (this.icon != null)
	    data['icon'] = this.icon;
    if (this.limit != null)
	    data['limit'] = this.limit;
    if (this.name != null)
	    data['name'] = this.name;
    if (this.cost != null)
      data['cost'] = this.cost!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [id, icon, limit, name, cost, createdBy];
}
