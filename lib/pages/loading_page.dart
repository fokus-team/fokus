import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:fokus/bloc/active_user/active_user_cubit.dart';
import 'package:fokus/bloc/app_init/app_init_state.dart';

import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/data/model/user/user_role.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/bloc/app_init/app_init_cubit.dart';
import 'package:fokus/data/model/button_type.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/bloc/user_restore/user_restore_cubit.dart';
import 'package:fokus/bloc/user_restore/user_restore_state.dart';

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
								showAlertDialog(context, 'alert.error', 'alert.noConnection', ButtonType.retry, () => _retryInitialization(context));
							else if (state is AppInitSuccess)
								CubitProvider.of<UserRestoreCubit>(context).restoreUser();
						},
					),
					CubitListener<UserRestoreCubit, UserRestoreState>(
						listener: (BuildContext context, UserRestoreState state) {
							if (state is UserRestoreFailure)
								Navigator.of(context).pushReplacementNamed(AppPage.rolesPage.name);
							else if (state is UserRestoreSuccess) {
								var userRoute = state.userRole == UserRole.child ? AppPage.childPanel : AppPage.caregiverPanel;
								Navigator.of(context).pushReplacementNamed(userRoute.name);
							}
						},
					),
				],
				child: _buildPage(context)
			)
		);
	}

	Widget _buildPage(BuildContext context) {
		return PageTheme.loginSection(
			child: Scaffold(
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
			),
		);
	}

	void _retryInitialization(BuildContext context) {
		CubitProvider.of<AppInitCubit>(context).initializeApp();
		Navigator.of(context).pop();
	}
}
