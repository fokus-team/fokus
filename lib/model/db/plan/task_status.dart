import '../../../utils/definitions.dart';

class TaskStatus {
	bool? completed;
	TaskState? state;
	int? pointsAwarded;
	int? rating;
	String? comment;

	TaskStatus({this.completed, this.state, this.pointsAwarded, this.rating, this.comment});

	static TaskStatus? fromJson(Json? json) {
		return json != null ? TaskStatus(
			completed: json['completed'],
			state: json['state'] != null ? TaskState.values[json['state']] : null,
			pointsAwarded: json['pointsAwarded'],
			rating: json['rating'],
			comment: json['comment'],
		) : null;
	}

	Json toJson() {
		final data = <String, dynamic>{};
		if (completed != null)
			data['completed'] = completed;
		if (state != null)
			data['state'] = state!.index;
		if (pointsAwarded != null)
			data['pointsAwarded'] = pointsAwarded;
		if (rating != null)
			data['rating'] = rating;
		if (comment != null)
			data['comment'] = comment;
		return data;
	}
}

enum TaskState {
	notEvaluated, evaluated, rejected
}
