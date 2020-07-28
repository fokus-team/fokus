import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:fokus/model/app_page.dart';
import 'package:fokus/model/button_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/logic/app_init/app_init_cubit.dart';
import 'package:fokus/logic/app_init/app_init_state.dart';
import 'package:fokus/logic/user_restore/user_restore_cubit.dart';
import 'package:fokus/logic/user_restore/user_restore_state.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/utils/theme_config.dart';

class LoadingPage extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MultiCubitProvider(
			providers: [
				CubitProvider<AppInitCubit>(create: (BuildContext context) => AppInitCubit()),
				CubitProvider<UserRestoreCubit>(create: (BuildContext context) => UserRestoreCubit(CubitProvider.of<ActiveUserCubit>(context))),
			],
			child: MultiBlocListener(
				listeners: [
					CubitListener<AppInitCubit, AppInitState>(
						listener: (BuildContext context, AppInitState state) {
							if (state is AppInitFailure)
								showAlertDialog(context, 'alert.noConnection', 'alert.connectionRetry', ButtonType.retry, () => _retryInitialization(context));
							else if (state is AppInitSuccess)
								CubitProvider.of<UserRestoreCubit>(context).restoreUser();
						},
					),
					CubitListener<UserRestoreCubit, UserRestoreState>(
						listener: (BuildContext context, UserRestoreState state) {
							Navigator.of(context).pushReplacementNamed((state is UserRestoreSuccess ? state.userRole.panelPage : AppPage.rolesPage).name);
						},
					),
				],
				child: _buildPage(context)
			)
		);
	}

	Widget _buildPage(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.mainBackgroundColor,
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: <Widget>[
						// TODO Change Circular Indicator to our sunflower animation
						Padding(padding: EdgeInsets.only(bottom: 20.0), child: CircularProgressIndicator(backgroundColor: Colors.white)),
						Text('${AppLocales.of(context).translate("loading")}...', style: Theme.of(context).textTheme.bodyText1)
					]
				),
			)
		);
	}

	void _retryInitialization(BuildContext context) {
		CubitProvider.of<AppInitCubit>(context).initializeApp();
		Navigator.of(context).pop();
	}
}
