import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/bloc/app_init/bloc.dart';
import 'package:fokus/data/model/button_type.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';

class LoadingPage extends StatelessWidget {
	LoadingPage();

	@override
	Widget build(BuildContext context) {
		return BlocProvider(
			create: (BuildContext context) => AppInitBloc()..add(AppInitEvent.INITIALIZATION_STARTED),
			child: BlocListener<AppInitBloc, AppInitState>(
				listener: (BuildContext context, AppInitState state) {
					if (state == AppInitState.APP_DISCONNECTED)
				    showAlertDialog(context, 'alert.error', 'alert.noConnection', ButtonType.RETRY, () => _retryInitialization(context));
					else if (state == AppInitState.APP_INITIALIZED)
						Navigator.of(context).pushReplacementNamed('/main-page');
				},
				child: Scaffold(
					body: Center(child: Text('${AppLocales.of(context).translate("loading")}...', style: TextStyle(fontSize: 30))),
				),
			)
		);
	}

	void _retryInitialization(BuildContext context) {
		BlocProvider.of<AppInitBloc>(context).add(AppInitEvent.INITIALIZATION_STARTED);
		Navigator.of(context).pop();
	}
}
