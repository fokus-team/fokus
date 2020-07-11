import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/data/model/app_page.dart';
import 'package:fokus/data/model/user/child.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/bloc/app_init/bloc.dart';
import 'package:fokus/data/model/button_type.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/bloc/user_restore/user_restore_cubit.dart';
import 'package:fokus/bloc/user_restore/user_restore_state.dart';

class LoadingPage extends StatelessWidget {
	LoadingPage();

	@override
	Widget build(BuildContext context) {
		return MultiBlocProvider(
			providers: [
				BlocProvider<AppInitBloc>(create: (BuildContext context) => AppInitBloc()..add(AppInitStarted())),
				CubitProvider<UserRestoreCubit>(create: (BuildContext context) => UserRestoreCubit()),
			],
			child: MultiBlocListener(
				listeners: [
					BlocListener<AppInitBloc, AppInitState>(
						listener: (BuildContext context, AppInitState state) {
							if (state is AppInitFailure)
								showAlertDialog(context, 'alert.error', 'alert.noConnection', ButtonType.retry, () => _retryInitialization(context));
							else if (state is AppInitSuccess)
								CubitProvider.of<UserRestoreCubit>(context).initiateUserRestore();
						},
					),
					CubitListener<UserRestoreCubit, UserRestoreState>(
						listener: (BuildContext context, UserRestoreState state) {
							if (state is UserRestoreFailure)
								Navigator.of(context).pushReplacementNamed(AppPage.rolesPage.name);
							else if (state is UserRestoreSuccess) {
								var userRoute = state.user is Child ? AppPage.childPanel : AppPage.caregiverPanel;
								Navigator.of(context).pushReplacementNamed(userRoute.name, arguments: state.user);
							}
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
		BlocProvider.of<AppInitBloc>(context).add(AppInitStarted());
		Navigator.of(context).pop();
	}
}
