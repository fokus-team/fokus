import 'package:equatable/equatable.dart';

import '../../../utils/definitions.dart';
import '../date/date.dart';
import '../date_span.dart';
import 'repeatability_type.dart';

class PlanRepeatability extends Equatable {
  final List<int>? days;
  final DateSpan<Date>? range;
  final RepeatabilityType? type;
  final bool? untilCompleted;

  PlanRepeatability({this.days, this.range, this.type, this.untilCompleted});

  PlanRepeatability.fromJson(Json json) : this(
    days: json['days'] != null ? List<int>.from(json['days']) : null,
    range: json['range'] != null ? DateSpan.fromJson<Date>(json['range']) : null,
    type: RepeatabilityType.values[json['type']],
    untilCompleted: json['untilCompleted'] ?? false,
  );

  Json toJson() {
	  final data = <String, dynamic>{};
    if (type != null)
	    data['type'] = type!.index;
    if (untilCompleted != null)
	    data['untilCompleted'] = untilCompleted;
    if (days != null)
      data['days'] = days;
    if (range != null)
      data['range'] = range!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [type, untilCompleted, days, range];
}
