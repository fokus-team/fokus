import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../../utils/definitions.dart';

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
	  final data = <String, dynamic>{};
    if (createdBy != null)
	    data['createdBy'] = createdBy;
    if (id != null)
	    data['_id'] = id;
    if (icon != null)
	    data['icon'] = icon;
    if (limit != null)
	    data['limit'] = limit;
    if (name != null)
	    data['name'] = name;
    if (cost != null)
      data['cost'] = cost!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [id, icon, limit, name, cost, createdBy];
}
