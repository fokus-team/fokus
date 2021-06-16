import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../date/time_date.dart';
import 'points.dart';
import 'reward.dart';

class ChildReward extends Reward {
  final TimeDate? date;

  ChildReward({ObjectId? id, String? name, Points? cost, this.date, int? icon}) : super(id: id, name: name, cost: cost, icon: icon);

  ChildReward.fromJson(Json json) : date = TimeDate.parseDBDate(json['date']), super.fromJson(json);

  @override
  Json toJson() {
	  final data = super.toJson();
    if (date != null)
      data['date'] = date!.toDBDate();
    return data;
  }

	@override
  ChildReward copyWith({String? name, int? limit, Points? cost, int? icon, ObjectId? createdBy, ObjectId? id, TimeDate? date}) {
		return ChildReward(
				name: name ?? this.name,
				cost: cost ?? this.cost,
				icon: icon ?? this.icon,
				id: id ?? this.id,
				date: date ?? this.date
		);
	}

	@override
	List<Object?> get props => super.props..add(date);
}
