import 'package:fokus/utils/definitions.dart';

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
		final Json data = new Json();
		if (this.completed != null)
			data['completed'] = this.completed;
		if (this.state != null)
			data['state'] = this.state!.index;
		if (this.pointsAwarded != null)
			data['pointsAwarded'] = this.pointsAwarded;
		if (this.rating != null)
			data['rating'] = this.rating;
		if (this.comment != null)
			data['comment'] = this.comment;
		return data;
	}
}

enum TaskState {
	notEvaluated, evaluated, rejected
}
