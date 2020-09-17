import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/icon_sets.dart';

import 'notification_channel.dart';

enum NotificationType {
	rewardBought,
	taskFinished,
	planUnfinished,
	pointsReceived,
	badgeAwarded
}

const String _pageKey = "page.notifications.content";

extension NotificationTypeExtension on NotificationType {
	String get title => {
		NotificationType.rewardBought: "$_pageKey.caregiver.rewardBought",
		NotificationType.taskFinished: "$_pageKey.caregiver.taskFinished",
		NotificationType.planUnfinished: "$_pageKey.caregiver.planUnfinished",
		NotificationType.pointsReceived: "$_pageKey.child.pointsReceived",
		NotificationType.badgeAwarded: "$_pageKey.child.badgeAwarded"
	}[this];

	Icon get icon => Icon(
		const {
			NotificationType.rewardBought : Icons.star,
			NotificationType.taskFinished : Icons.assignment_turned_in,
			NotificationType.planUnfinished : Icons.assignment_late,
			NotificationType.pointsReceived : Icons.assignment_turned_in,
			NotificationType.badgeAwarded : Icons.star
		}[this],
		color: Colors.grey
	);

	AssetType get graphicType => const {
		NotificationType.rewardBought: AssetType.avatars,
		NotificationType.taskFinished: AssetType.avatars,
		NotificationType.planUnfinished: AssetType.avatars,
		NotificationType.pointsReceived: AssetType.currencies,
		NotificationType.badgeAwarded: AssetType.badges
	}[this];

	AppPage get redirectPage => const {
		NotificationType.rewardBought: AppPage.caregiverChildDashboard,
		NotificationType.taskFinished: AppPage.caregiverRatingPage,
		NotificationType.planUnfinished: AppPage.caregiverChildDashboard,
		NotificationType.pointsReceived: AppPage.caregiverAwards,
		NotificationType.badgeAwarded: AppPage.childAchievements
	}[this];

	NotificationChannel get channel => const {
		NotificationType.rewardBought: NotificationChannel.prizes,
		NotificationType.taskFinished: NotificationChannel.grades,
		NotificationType.pointsReceived: NotificationChannel.grades,
		NotificationType.badgeAwarded: NotificationChannel.prizes,
		NotificationType.planUnfinished: NotificationChannel.plans,
	}[this];
}
