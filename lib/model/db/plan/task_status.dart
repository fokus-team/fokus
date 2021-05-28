import 'package:fokus/utils/definitions.dart';

class TaskStatus {
	bool? completed;
	TaskState? state;
	int? pointsAwarded;
	int? rating;

	TaskStatus({this.completed, this.state, this.pointsAwarded, this.rating});

	static TaskStatus? fromJson(Json? json) {
		return json != null ? TaskStatus(
			completed: json['completed'],
			state: json['state'] != null ? TaskState.values[json['state']] : null,
			pointsAwarded: json['pointsAwarded'],
			rating: json['rating'],
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
		return data;
	}
}

enum TaskState {
	notEvaluated, evaluated, rejected
}
