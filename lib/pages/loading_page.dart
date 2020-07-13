import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/data/repository/settings/app_config_repository.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/bloc/app_init/bloc.dart';
import 'package:fokus/data/model/button_type.dart';
import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/wigets/page_theme.dart';

class LoadingPage extends StatelessWidget {
	LoadingPage();

	@override
	Widget build(BuildContext context) {
		return BlocProvider(
			create: (BuildContext context) => AppInitBloc(RepositoryProvider.of<DataRepository>(context),
					RepositoryProvider.of<AppConfigRepository>(context))..add(AppInitStartedEvent()),
			child: BlocListener<AppInitBloc, AppInitState>(
				listener: (BuildContext context, AppInitState state) {
					if (state is AppInitFailureState)
				    showAlertDialog(context, 'alert.error', 'alert.noConnection', ButtonType.retry, () => _retryInitialization(context));
					else if (state is AppInitSuccessState)
						Navigator.of(context).pushReplacementNamed('/roles-page', arguments: state.user);
				},
				child: PageTheme.loginSection(
					child: Scaffold(
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
				)
			)
		);
	}

	void _retryInitialization(BuildContext context) {
		BlocProvider.of<AppInitBloc>(context).add(AppInitStartedEvent());
		Navigator.of(context).pop();
	}
}
