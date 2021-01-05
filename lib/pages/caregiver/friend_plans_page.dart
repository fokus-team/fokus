import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/caregiver/caregiver_friends_cubit.dart';
import 'package:fokus/logic/caregiver/caregiver_plans_cubit.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class CaregiverFriendPlansPage extends StatefulWidget {
	@override
	_CaregiverFriendPlansPageState createState() => new _CaregiverFriendPlansPageState();
}

class _CaregiverFriendPlansPageState extends State<CaregiverFriendPlansPage> {
	static const String _pageKey = 'page.caregiverSection.friendPlans';
	
	@override
	Widget build(BuildContext context) {
		final MapEntry<Mongo.ObjectId, String> friend = ModalRoute.of(context).settings.arguments;
    return Scaffold(
			appBar: AppBar(
				title: Text(friend.value),
				actions: <Widget>[
					HelpIconButton(helpPage: 'friends'),
					PopupMenuList(
						lightTheme: true,
						items: [
							UIButton(
								'$_pageKey.content.removeFriendTitle',
								() {
									showBasicDialog(
										context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('$_pageKey.content.removeFriendTitle'),
											content: AppLocales.of(context).translate('$_pageKey.content.removeFriendText'),
											confirmColor: Colors.red,
											confirmText: 'actions.delete',
											confirmAction: () => _deleteFriend(friend.key)
										)
									);
								},
								null,
								Icons.person_remove
							)
						]
					)
				]
			),
			body: _buildFriendPlans()
    );
	}

	void _deleteFriend(Mongo.ObjectId friendID) {
		BlocProvider.of<CaregiverFriendsCubit>(context).removeFriend(friendID);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		Navigator.of(context).popAndPushNamed(AppPage.caregiverPanel.name);
		showSuccessSnackbar(context, '$_pageKey.content.friendRemovedText');
	}

	Widget _buildFriendPlans() {
		return LoadableBlocBuilder<CaregiverPlansCubit>(
			builder: (context, state) => Segment(
				title: '$_pageKey.content.plansTitle',
				noElementsMessage: '$_pageKey.content.noPlansText',
				elements: <Widget>[
					for (var plan in (state as CaregiverPlansLoadSuccess).plans)
						ItemCard(
							title: plan.name,
							subtitle: plan.description(context),
							onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
							chips: <Widget>[
								AttributeChip.withIcon(
									content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': plan.taskCount}),
									color: Colors.indigo,
									icon: Icons.layers
								)
							]
						)
				]
			)
		);
	}

}
