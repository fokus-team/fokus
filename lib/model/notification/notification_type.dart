import 'package:flutter/material.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/ui/icon_sets.dart';

import 'notification_channel.dart';

enum NotificationType {
	rewardBought,
	taskFinished,
	taskUnfinished,
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
		NotificationType.taskUnfinished: "caregiver.taskUnfinished",
		NotificationType.taskApproved: "child.taskApproved",
		NotificationType.badgeAwarded: "child.badgeAwarded",
		NotificationType.taskRejected: "child.taskRejected"
	}[this]!;

	Icon get icon => Icon(
		const {
			NotificationType.rewardBought : Icons.star,
			NotificationType.taskFinished : Icons.assignment_turned_in,
			NotificationType.taskUnfinished : Icons.assignment_late,
			NotificationType.taskApproved : Icons.assignment_turned_in,
			NotificationType.badgeAwarded : Icons.star,
			NotificationType.taskRejected : Icons.assignment_late,
		}[this],
		color: Colors.grey
	);

	AssetType get graphicType => const {
		NotificationType.rewardBought: AssetType.avatars,
		NotificationType.taskFinished: AssetType.avatars,
		NotificationType.taskUnfinished: AssetType.avatars,
		NotificationType.taskApproved: AssetType.currencies,
		NotificationType.badgeAwarded: AssetType.badges,
	}[this]!;

	AppPage get redirectPage => const {
		NotificationType.rewardBought: AppPage.caregiverChildDashboard,
		NotificationType.taskFinished: AppPage.caregiverRatingPage,
		NotificationType.taskUnfinished: AppPage.caregiverChildDashboard,
		NotificationType.taskApproved: AppPage.planInstanceDetails,
		NotificationType.badgeAwarded: AppPage.childAchievements,
		NotificationType.taskRejected: AppPage.planInstanceDetails,
	}[this]!;

	UserRole get recipient => const {
		NotificationType.rewardBought: UserRole.caregiver,
		NotificationType.taskFinished: UserRole.caregiver,
		NotificationType.taskUnfinished: UserRole.caregiver,
		NotificationType.taskApproved: UserRole.child,
		NotificationType.badgeAwarded: UserRole.child,
		NotificationType.taskRejected: UserRole.child,
	}[this]!;

	NotificationChannel get channel => const {
		NotificationType.rewardBought: NotificationChannel.prizes,
		NotificationType.taskFinished: NotificationChannel.plans,
		NotificationType.taskUnfinished: NotificationChannel.plans,
		NotificationType.taskApproved: NotificationChannel.grades,
		NotificationType.badgeAwarded: NotificationChannel.prizes,
		NotificationType.taskRejected: NotificationChannel.grades,
	}[this]!;
}
