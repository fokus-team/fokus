import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/duration.dart';

import 'repeatability_type.dart';

class PlanRepeatability {
  List<int> days;
  Duration<Date> range;
  RepeatabilityType type;
  bool untilCompleted;

  PlanRepeatability({this.days, this.range, this.type, this.untilCompleted});

  factory PlanRepeatability.fromJson(Map<String, dynamic> json) {
    return PlanRepeatability(
      days: json['days'] != null ? new List<int>.from(json['days']) : null,
      range: json['range'] != null ? Duration.fromJson(json['range']) : null,
      type: RepeatabilityType.values[json['type']],
      untilCompleted: json['untilCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type.index;
    data['untilCompleted'] = this.untilCompleted;
    if (this.days != null) {
      data['days'] = this.days;
    }
    if (this.range != null) {
      data['range'] = this.range.toJson();
    }
    return data;
  }
}
