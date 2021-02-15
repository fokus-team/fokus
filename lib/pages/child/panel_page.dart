import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/child/child_panel_cubit.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/widgets/custom_app_bars.dart';
import 'package:fokus/utils/ui/child_plans_util.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/app_navigation_bar.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';
import 'package:fokus/widgets/segment.dart';

class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => new _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	static const String _pageKey = 'page.childSection.panel';

  @override
  Widget build(BuildContext context) {
		UIChild currentUser = BlocProvider.of<AuthenticationBloc>(context).state.user;
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
	      children: [
		      SimpleStatefulBlocBuilder<ChildPanelCubit, ChildPlansState>(
				    builder: (context, state) => AppSegments(segments: buildChildPlanSegments(state.plans, context)),
						expandLoader: true,
		      ),
	        CustomChildAppBar()
	      ]
      ),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => Navigator.of(context).pushNamed(AppPage.childCalendar.name, arguments: currentUser.id),
				label: Text(AppLocales.of(context).translate('$_pageKey.content.futurePlans')),
				icon: Icon(Icons.calendar_today),
				backgroundColor: AppColors.childButtonColor,
				elevation: 4.0
			),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: AppNavigationBar.childPage(currentIndex: 0)
    );
  }
}
