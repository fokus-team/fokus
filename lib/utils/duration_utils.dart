import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';

Duration sumDurations(List<DateSpan<TimeDate>> durations) {
	if (durations != null || durations.isEmpty)
		return Duration();
	var sum = durations.sublist(0, durations.length - 1).fold<Duration>(Duration(), (sum, span) => sum + span.to.difference(span.from));
	var lastSpanEnd = durations.last.to ?? TimeDate.now();
	return sum + lastSpanEnd.difference(durations.last.from);
}
