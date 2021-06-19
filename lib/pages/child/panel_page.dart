import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/child/child_panel_cubit.dart';
import '../../logic/common/auth_bloc/authentication_bloc.dart';
import '../../model/db/user/child.dart';
import '../../model/ui/app_page.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/child_plans_util.dart';
import '../../utils/ui/theme_config.dart';
import '../../widgets/app_navigation_bar.dart';
import '../../widgets/custom_app_bars.dart';
import '../../widgets/segment.dart';
import '../../widgets/stateful_bloc_builder.dart';

class ChildPanelPage extends StatefulWidget {
  @override
  _ChildPanelPageState createState() => _ChildPanelPageState();
}

class _ChildPanelPageState extends State<ChildPanelPage> {
	static const String _pageKey = 'page.childSection.panel';

  @override
  Widget build(BuildContext context) {
  	var authState = BlocProvider.of<AuthenticationBloc>(context).state;
  	if (!authState.signedIn)
  		return Container();
		var currentUser = authState.user! as Child;
    return Scaffold(
      body: Column(
	      crossAxisAlignment: CrossAxisAlignment.start,
				verticalDirection: VerticalDirection.up,
	      children: [
		      StatefulBlocBuilder<ChildPanelCubit, ChildPlansData>(
				    builder: (context, state) => AppSegments(segments: buildChildPlanSegments(state.data!.plans, context)),
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
