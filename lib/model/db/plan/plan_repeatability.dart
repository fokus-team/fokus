import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/utils/definitions.dart';

import 'repeatability_type.dart';

class PlanRepeatability extends Equatable {
  final List<int>? days;
  final DateSpan<Date>? range;
  final RepeatabilityType? type;
  final bool? untilCompleted;

  PlanRepeatability({this.days, this.range, this.type, this.untilCompleted});

  PlanRepeatability.fromJson(Json json) : this(
    days: json['days'] != null ? new List<int>.from(json['days']) : null,
    range: json['range'] != null ? DateSpan.fromJson<Date>(json['range']) : null,
    type: RepeatabilityType.values[json['type']],
    untilCompleted: json['untilCompleted'] ?? false,
  );

  Json toJson() {
    final Json data = new Json();
    if (this.type != null)
	    data['type'] = this.type!.index;
    if (this.untilCompleted != null)
	    data['untilCompleted'] = this.untilCompleted;
    if (this.days != null)
      data['days'] = this.days;
    if (this.range != null)
      data['range'] = this.range!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [type, untilCompleted, days, range];
}
