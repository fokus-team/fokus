import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../../logic/caregiver/caregiver_friends_cubit.dart';
import '../../logic/caregiver/caregiver_plans_cubit.dart';
import '../../model/ui/app_page.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/dialog_utils.dart';
import '../../utils/ui/snackbar_utils.dart';
import '../../widgets/buttons/help_icon_button.dart';
import '../../widgets/buttons/popup_menu_list.dart';
import '../../widgets/cards/item_card.dart';
import '../../widgets/chips/attribute_chip.dart';
import '../../widgets/dialogs/general_dialog.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class CaregiverFriendPlansPage extends StatelessWidget {
	static const String _pageKey = 'page.caregiverSection.friendPlans';

	@override
	Widget build(BuildContext context) {
		final friend = ModalRoute.of(context)!.settings.arguments as MapEntry<mongo.ObjectId, String>;
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
											confirmAction: () => _deleteFriend(friend.key, context)
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

	void _deleteFriend(mongo.ObjectId friendID, BuildContext context) {
		BlocProvider.of<CaregiverFriendsCubit>(context).removeFriend(friendID);
		Navigator.of(context).pop(); // closing confirm dialog before pushing snackbar
		Navigator.of(context).popAndPushNamed(AppPage.caregiverPanel.name);
		showSuccessSnackbar(context, '$_pageKey.content.friendRemovedText');
	}

	Widget _buildFriendPlans() {
		return StatefulBlocBuilder<CaregiverPlansCubit, CaregiverPlansData>(
			builder: (context, state) => Segment(
				title: '$_pageKey.content.plansTitle',
				noElementsMessage: '$_pageKey.content.noPlansText',
				elements: <Widget>[
					for (var plan in state.data!.plans)
						ItemCard(
							title: plan.name!,
							subtitle: plan.description,
							onTapped: () => Navigator.of(context).pushNamed(AppPage.planDetails.name, arguments: plan.id),
							chips: <Widget>[
								AttributeChip.withIcon(
									content: AppLocales.of(context).translate('page.caregiverSection.plans.content.tasks', {'NUM_TASKS': plan.tasks!.length}),
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
