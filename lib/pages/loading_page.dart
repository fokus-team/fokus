import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/utils/theme_config.dart';

import 'package:fokus/bloc/app_init/bloc.dart';
import 'package:fokus/data/model/button_type.dart';
import 'package:fokus/data/repository/database/data_repository.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/dialog_utils.dart';

class LoadingPage extends StatelessWidget {
	LoadingPage();

	@override
	Widget build(BuildContext context) {
		return BlocProvider(
			create: (BuildContext context) => AppInitBloc(RepositoryProvider.of<DataRepository>(context))..add(AppInitStartedEvent()),
			child: BlocListener<AppInitBloc, AppInitState>(
				listener: (BuildContext context, AppInitState state) {
					if (state is AppInitFailureState)
				    showAlertDialog(context, 'alert.error', 'alert.noConnection', ButtonType.RETRY, () => _retryInitialization(context));
					else if (state is AppInitSuccessState)
						Navigator.of(context).pushReplacementNamed('/main-page', arguments: state.user);
				},
				child: Scaffold(
          backgroundColor: ThemeConfig.mainBackgroundColor,
					body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // TODO Change Circular Indicator to our sunflower animation
              Center(child: Padding(padding: EdgeInsets.only(bottom: 10.0), child: CircularProgressIndicator(backgroundColor: Colors.white))),
              Center(child: Text('${AppLocales.of(context).translate("loading")}...', style: Theme.of(context).textTheme.bodyText2))
            ]
          ),
				),
			)
		);
	}

	void _retryInitialization(BuildContext context) {
		BlocProvider.of<AppInitBloc>(context).add(AppInitStartedEvent());
		Navigator.of(context).pop();
	}
}
