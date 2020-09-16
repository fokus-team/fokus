import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'notification_channel.dart';

enum NotificationType {
	caregiver_receivedReward,
	caregiver_finishedTaskUngraded,
	caregiver_unfinishedPlan,
	child_taskGraded,
	child_receivedBadge
}

extension NotificationTypeExtension on NotificationType {
	String get title => {
		NotificationType.caregiver_receivedReward: "caregiver.receivedReward",
		NotificationType.caregiver_finishedTaskUngraded: "caregiver.finishedTask",
		NotificationType.caregiver_unfinishedPlan: "caregiver.unfinishedPlan",
		NotificationType.child_taskGraded: "child.taskGraded",
		NotificationType.child_receivedBadge: "child.receivedBadge"
	}[this];

	Icon get icon => Icon(
		const {
			NotificationType.caregiver_receivedReward : Icons.star,
			NotificationType.caregiver_finishedTaskUngraded : Icons.assignment_turned_in,
			NotificationType.caregiver_unfinishedPlan : Icons.assignment_late,
			NotificationType.child_taskGraded : Icons.assignment_turned_in,
			NotificationType.child_receivedBadge : Icons.star
		}[this],
		color: Colors.grey
	);

	AssetType get graphicType => const {
		NotificationType.caregiver_receivedReward: AssetType.avatars,
		NotificationType.caregiver_finishedTaskUngraded: AssetType.avatars,
		NotificationType.caregiver_unfinishedPlan: AssetType.avatars,
		NotificationType.child_taskGraded: AssetType.currencies,
		NotificationType.child_receivedBadge: AssetType.badges
	}[this];

	AppPage get redirectPage => const {
		NotificationType.caregiver_receivedReward: AppPage.caregiverChildDashboard,
		NotificationType.caregiver_finishedTaskUngraded: AppPage.caregiverRatingPage,
		NotificationType.caregiver_unfinishedPlan: AppPage.caregiverChildDashboard,
		NotificationType.child_taskGraded: AppPage.caregiverAwards,
		NotificationType.child_receivedBadge: AppPage.childAchievements
	}[this];

	NotificationChannel get channel => const {
		NotificationType.caregiver_finishedTaskUngraded: NotificationChannel.grades,
		NotificationType.child_taskGraded: NotificationChannel.grades,
		NotificationType.caregiver_receivedReward: NotificationChannel.prizes,
		NotificationType.child_receivedBadge: NotificationChannel.prizes,
		NotificationType.caregiver_unfinishedPlan: NotificationChannel.plans,
	}[this];
}
