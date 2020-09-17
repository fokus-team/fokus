import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'notification_channel.dart';

enum NotificationType {
	rewardBought,
	taskFinished,
	planUnfinished,
	taskGraded,
	badgeAwarded
}

extension NotificationTypeExtension on NotificationType {
	String get title => {
		NotificationType.rewardBought: "caregiver.receivedReward",
		NotificationType.taskFinished: "caregiver.finishedTask",
		NotificationType.planUnfinished: "caregiver.unfinishedPlan",
		NotificationType.taskGraded: "child.taskGraded",
		NotificationType.badgeAwarded: "child.receivedBadge"
	}[this];

	Icon get icon => Icon(
		const {
			NotificationType.rewardBought : Icons.star,
			NotificationType.taskFinished : Icons.assignment_turned_in,
			NotificationType.planUnfinished : Icons.assignment_late,
			NotificationType.taskGraded : Icons.assignment_turned_in,
			NotificationType.badgeAwarded : Icons.star
		}[this],
		color: Colors.grey
	);

	AssetType get graphicType => const {
		NotificationType.rewardBought: AssetType.avatars,
		NotificationType.taskFinished: AssetType.avatars,
		NotificationType.planUnfinished: AssetType.avatars,
		NotificationType.taskGraded: AssetType.currencies,
		NotificationType.badgeAwarded: AssetType.badges
	}[this];

	AppPage get redirectPage => const {
		NotificationType.rewardBought: AppPage.caregiverChildDashboard,
		NotificationType.taskFinished: AppPage.caregiverRatingPage,
		NotificationType.planUnfinished: AppPage.caregiverChildDashboard,
		NotificationType.taskGraded: AppPage.caregiverAwards,
		NotificationType.badgeAwarded: AppPage.childAchievements
	}[this];

	NotificationChannel get channel => const {
		NotificationType.taskFinished: NotificationChannel.grades,
		NotificationType.taskGraded: NotificationChannel.grades,
		NotificationType.rewardBought: NotificationChannel.prizes,
		NotificationType.badgeAwarded: NotificationChannel.prizes,
		NotificationType.planUnfinished: NotificationChannel.plans,
	}[this];
}
