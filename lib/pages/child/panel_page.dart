import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/child/child_plans_cubit.dart';
import 'package:fokus/logic/common/timer/timer_cubit.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:fokus/utils/ui/child_plans_util.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/loadable_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';


class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	static const String _pageKey = 'page.childSection.panel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
	      children: [
	        ChildCustomHeader(),
		      LoadableBlocBuilder<ChildPlansCubit>(
				    builder: (context, state) => AppSegments(segments: _buildPanelSegments(state)),
						wrapWithExpanded: true,
		      )
	      ]
      ),
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }

  List<Widget> _buildPanelSegments(ChildPlansLoadSuccess state) {
		UIChild currentUser = context.bloc<AuthenticationBloc>().state.user;

    return [
			...buildChildPlanSegments(state.plans, context),
			Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: <Widget>[
					RoundedButton(
						icon: Icons.calendar_today,
						text: AppLocales.of(context).translate('$_pageKey.content.futurePlans'),
						color: AppColors.childButtonColor,
						onPressed: () => Navigator.of(context).pushNamed(AppPage.childCalendar.name, arguments: currentUser.id)
					)
				]
			)
    ];
  }
}
