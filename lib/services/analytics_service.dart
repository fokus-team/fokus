import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/task/ui_task_report.dart';
import 'package:fokus_auth/fokus_auth.dart';

class AnalyticsService {
	final FirebaseAnalytics _analytics = FirebaseAnalytics();

	FirebaseAnalyticsObserver get pageObserver => FirebaseAnalyticsObserver(analytics: _analytics);

	// Authentication
	void logSignUp(AuthMethod method) => _analytics.logSignUp(signUpMethod: method.name);
	void logSignIn(AuthMethod method) => _analytics.logLogin(loginMethod: method.name);
	void logChildSignUp() => _analytics.logEvent(name: 'child_sign_up');
	void logChildSignIn() => _analytics.logEvent(name: 'child_login');

	// Plan
	void logPlanCreated(Plan plan) => _analytics.logEvent(name: 'plan_created', parameters: {
		'id': plan.id?.toHexString(),
		'task_count': plan.tasks?.length,
		'repeatability': plan.repeatability?.type?.name
	});
	void logPlanStarted(PlanInstance plan) => _analytics.logEvent(name: 'plan_started', parameters: plan.logRecord);
	void logPlanCompleted(PlanInstance plan) => _analytics.logEvent(name: 'plan_completed', parameters: plan.logRecord);
	void logPlanResumed(PlanInstance plan) => _analytics.logEvent(name: 'plan_resumed', parameters: plan.logRecord);

	// Task
	void logTaskStarted(TaskInstance task) => _analytics.logEvent(name: 'task_started', parameters: task.logRecord);
	void logTaskFinished(TaskInstance task) => _analytics.logEvent(name: 'task_finished', parameters: task.logRecord);
	void logTaskNotFinished(TaskInstance task) => _analytics.logEvent(name: 'task_not_finished', parameters: task.logRecord);
	void logTaskPaused(TaskInstance task) => _analytics.logEvent(name: 'task_paused', parameters: task.logRecord);
	void logTaskResumed(TaskInstance task) => _analytics.logEvent(name: 'task_resumed', parameters: task.logRecord);
	void logTaskApproved(UITaskReport task) => _analytics.logEvent(name: 'task_approved', parameters: task.logRecord);
	void logTaskRejected(UITaskReport task) => _analytics.logEvent(name: 'task_rejected', parameters: task.logRecord);

	// Reward
	void logRewardCreated(Reward reward) => _analytics.logEvent(name: 'reward_created', parameters: reward.logRecord);
	void logRewardBought(UIReward reward) => _analytics.logEvent(name: 'reward_bought', parameters: reward.logRecord);

	// Badge
	void logBadgeCreated(Badge badge) => _analytics.logEvent(name: 'badge_created');
	void logBadgeAwarded(Badge badge) => _analytics.logEvent(name: 'badge_awarded');

	void logAppOpen() => _analytics.logAppOpen();
	void setUserId(String id) => _analytics.setUserId(id);
}

extension LogPlanInstance on PlanInstance {
	Map<String, dynamic> get logRecord => {
		'id': id?.toHexString(),
		'plan_id': planID?.toHexString()
	};
}

extension LogTaskInstance on TaskInstance {
	Map<String, dynamic> get logRecord => {
		'id': id?.toHexString(),
		'task_id': taskID?.toHexString(),
		'plan_id': planInstanceID?.toHexString(),
		'subtask_count': '${subtasks?.length}'
	};
}

extension LogUITaskReport on UITaskReport {
	Map<String, dynamic> get logRecord => {
		'child_id': child.id.toHexString(),
		'id': task.id.toHexString(),
		'rating': '${ratingMark.value}'
	};
}

extension LogReward on Reward {
	Map<String, dynamic> get logRecord => {
		'id': id?.toHexString(),
		'cost': '${cost?.quantity}',
		'currency': '${cost?.icon?.index}',
		'limit': '$limit'
	};
}

extension LogUIReward on UIReward {
	Map<String, dynamic> get logRecord => {
		'id': id.toHexString(),
		'cost': '${cost.quantity}',
		'currency': '$icon',
		'limit': '$limit'
	};
}
