import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildReward extends Reward {
  final TimeDate? date;

  ChildReward({ObjectId? id, String? name, Points? cost, this.date, int? icon}) : super(id: id, name: name, cost: cost, icon: icon);

  ChildReward.fromJson(Json json) : date = TimeDate.parseDBDate(json['date']), super.fromJson(json);

  Json toJson() {
	  final Json data = super.toJson();
    if (this.date != null)
      data['date'] = this.date!.toDBDate();
    return data;
  }

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
