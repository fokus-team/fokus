import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/date_span.dart';

int getTaskTimeInSeconds(List<DateSpan<TimeDate>> timeSpans) {
	int sum = 0;
	for(var span in timeSpans) {
		if(span.to != null)	sum += span.to.difference(span.from).inSeconds;
		else sum += TimeDate.now().difference(span.from).inSeconds;
	}
	return sum;
}
