import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/caregiver_awards_cubit.dart';
import 'package:fokus/logic/reward_form/reward_form_cubit.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/snackbar_utils.dart';

import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class CaregiverAwardsPage extends StatefulWidget {
	@override
	_CaregiverAwardsPageState createState() => new _CaregiverAwardsPageState();
}

class _CaregiverAwardsPageState extends State<CaregiverAwardsPage> {
	static const String _pageKey = 'page.caregiverSection.awards';
	
	@override
	Widget build(BuildContext context) {
    return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					AppHeader.normal(title: '$_pageKey.header.title', text: '$_pageKey.header.pageHint', headerActionButtons: [
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addReward', 
						() => Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name)),
						HeaderActionButton.normal(Icons.add, '$_pageKey.header.addBadge', 
						() => Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name))
					]),
					LoadableBlocBuilder<CaregiverAwardsCubit>(
						builder: (context, state) => AppSegments(segments: _buildPanelSegments(state, context))
					)
				]
			),
			bottomNavigationBar: AppNavigationBar.caregiverPage(currentIndex: 2)
    );
	}

	void _deleteReward(Mongo.ObjectId id) {
		context.bloc<CaregiverAwardsCubit>().removeReward(id);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		showSuccessSnackbar(context, '$_pageKey.content.rewardRemovedText');
	}

	List<Segment> _buildPanelSegments(CaregiverAwardsLoadSuccess state, BuildContext context) {
		return [
			Segment(
				title: '$_pageKey.content.addedRewardsTitle',
				noElementsMessage: '$_pageKey.content.noRewardsAdded',
				noElementsAction: RaisedButton(
					child: Text(
						AppLocales.of(context).translate('$_pageKey.header.addReward'),
						style: Theme.of(context).textTheme.button
					),
					onPressed: () => { Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name) }
				),
				elements: <Widget>[
					for (var reward in state.rewards)
						ItemCard(
							title: reward.name, 
							subtitle: AppLocales.of(context).translate((reward.limit != null || reward.limit == 0 ) ? 
								'$_pageKey.content.limitedReward' : '$_pageKey.content.unlimitedReward', {'REWARD_LIMIT': reward.limit.toString()}),
							menuItems: [
								UIButton.ofType(ButtonType.edit, () => { Navigator.of(context).pushNamed(AppPage.caregiverRewardForm.name, arguments: reward.id) }),
								UIButton.ofType(ButtonType.delete, () {
									showBasicDialog(context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeRewardTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeRewardText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => _deleteReward(reward.id)
										)
									);
								})
							],
							graphicType: GraphicAssetType.rewardsIcons,
							graphic: reward.icon,
							chips: <Widget>[
								if(reward.cost != null)
									AttributeChip.withCurrency(content: reward.cost.quantity.toString(), currencyType: reward.cost.type, tooltip: '$_pageKey.content.pointCost')
							],
						)
				]
			),
			Segment(
				title: '$_pageKey.content.addedBadgesTitle',
				noElementsMessage: '$_pageKey.content.noBadgesAdded',
				noElementsAction: RaisedButton(
					child: Text(
						AppLocales.of(context).translate('$_pageKey.header.addBadge'),
						style: Theme.of(context).textTheme.button
					),
					onPressed: () => { Navigator.of(context).pushNamed(AppPage.caregiverBadgeForm.name) }
				),
				elements: <Widget>[
					for (var badge in state.badges)
						ItemCard(
							title: badge.name, 
							subtitle: badge.maxLevel != null ? AppLocales.of(context).translate('$_pageKey.content.${badge.maxLevel.value}LeveledBadge') : '',
							menuItems: [
								UIButton.ofType(ButtonType.edit, () => {log("edit")}),
								UIButton.ofType(ButtonType.delete, () => {log("delete")})
							],
							graphicType: GraphicAssetType.badgeIcons,
							graphic: badge.icon,
							graphicHeight: 44.0
						)
				]
			)
		];
	}
}
