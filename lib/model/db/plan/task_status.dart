class TaskStatus {
	bool completed;
	TaskState state;
	int pointsAwarded;
	int rating;

	TaskStatus({this.completed, this.state, this.pointsAwarded, this.rating});

	factory TaskStatus.fromJson(Map<String, dynamic> json) {
		return json != null ? TaskStatus(
			completed: json['completed'],
			state: json['state'] != null ? TaskState.values[json['state']] : null,
			pointsAwarded: json['pointsAwarded'],
			rating: json['rating'],
		) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['completed'] = this.completed;
		data['state'] = this.state.index;
		data['pointsAwarded'] = this.pointsAwarded;
		data['rating'] = this.rating;
		return data;
	}
}

enum TaskState {
	notEvaluated, evaluated, rejected
}
