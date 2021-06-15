import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/user/child.dart';

class ChildCardModel extends Equatable {
	final int todayPlanCount;
	final bool hasActivePlan;
	final Child child;

	ChildCardModel({required this.todayPlanCount, required this.hasActivePlan, required this.child});

	ChildCardModel copyWith({Child? child, int? todayPlanCount, bool? hasActivePlan}) {
		return ChildCardModel(
			todayPlanCount: todayPlanCount ?? this.todayPlanCount,
			hasActivePlan: hasActivePlan ?? this.hasActivePlan,
			child: child ?? this.child
		);
	}

	@override
	List<Object?> get props => [todayPlanCount, hasActivePlan, child];
}
