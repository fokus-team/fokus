import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'notification_channel.dart';

enum NotificationType {
	rewardBought,
	taskFinished,
	planUnfinished,
	taskApproved,
	badgeAwarded,
	taskRejected,
}

const String _titleKey = "page.notifications.content";
const String _groupKey = "notification.group";

extension NotificationTypeExtension on NotificationType {
	String get title => '$_titleKey.$key';
	String get group => '$_groupKey.$key';

	String get key => {
		NotificationType.rewardBought: "caregiver.rewardBought",
		NotificationType.taskFinished: "caregiver.taskFinished",
		NotificationType.planUnfinished: "caregiver.planUnfinished",
		NotificationType.taskApproved: "child.taskApproved",
		NotificationType.badgeAwarded: "child.badgeAwarded",
		NotificationType.taskRejected: "child.taskRejected"
	}[this];

	Icon get icon => Icon(
		const {
			NotificationType.rewardBought : Icons.star,
			NotificationType.taskFinished : Icons.assignment_turned_in,
			NotificationType.planUnfinished : Icons.assignment_late,
			NotificationType.taskApproved : Icons.assignment_turned_in,
			NotificationType.badgeAwarded : Icons.star,
			NotificationType.taskRejected : Icons.assignment_late,
		}[this],
		color: Colors.grey
	);

	AssetType get graphicType => const {
		NotificationType.rewardBought: AssetType.avatars,
		NotificationType.taskFinished: AssetType.avatars,
		NotificationType.planUnfinished: AssetType.avatars,
		NotificationType.taskApproved: AssetType.currencies,
		NotificationType.badgeAwarded: AssetType.badges,
	}[this];

	AppPage get redirectPage => const {
		NotificationType.rewardBought: AppPage.caregiverChildDashboard,
		NotificationType.taskFinished: AppPage.caregiverRatingPage,
		NotificationType.planUnfinished: AppPage.caregiverChildDashboard,
		NotificationType.taskApproved: AppPage.caregiverAwards,
		NotificationType.badgeAwarded: AppPage.childAchievements,
		NotificationType.taskRejected: AppPage.childPlanInProgress,
	}[this];

	NotificationChannel get channel => const {
		NotificationType.rewardBought: NotificationChannel.prizes,
		NotificationType.taskFinished: NotificationChannel.plans,
		NotificationType.taskApproved: NotificationChannel.grades,
		NotificationType.badgeAwarded: NotificationChannel.prizes,
		NotificationType.planUnfinished: NotificationChannel.plans,
		NotificationType.taskRejected: NotificationChannel.grades,
	}[this];
}
