import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/app_error_type.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/auth/auth_button.dart';

class ErrorPage extends StatefulWidget {
	final AppErrorType errorType;

	ErrorPage(this.errorType);

	@override
	_ErrorPageState createState() => new _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
		String _localesPath = "page.error.${widget.errorType.toString().split('.')[1]}";
    return WillPopScope(
	    onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: <Widget>[
							Image.asset('assets/image/sunflower_jitter.gif', height: MediaQuery.of(context).size.width*0.5),
							Text(AppLocales.of(context).translate("$_localesPath.title"), style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white)),
							Text(AppLocales.of(context).translate("$_localesPath.subtitle"), style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center),
							Container(
								decoration: AppBoxProperties.elevatedContainer.copyWith(borderRadius: BorderRadius.all(Radius.circular(4.0))),
								margin: EdgeInsets.only(top: 24.0),
								padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
								child: Column(
									children: [
										Padding(
											padding: EdgeInsets.symmetric(vertical: 8.0),
											child: Text(AppLocales.of(context).translate("$_localesPath.hint"))
										),
										if (widget.errorType != AppErrorType.unknownError || Platform.isAndroid)
											AuthButton(
												button: UIButton("$_localesPath.action", () async {
													switch(widget.errorType) {
													  case AppErrorType.noConnectionError:
														  if ((await Connectivity().checkConnectivity()) != ConnectivityResult.none)
														  	Navigator.of(context).pop();
													    break;
													  case AppErrorType.unknownError:
													    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
													    break;
													}
												}, Colors.teal)
											)
										]
									)
								)
							]
						)
	        )
				)
      ),
    );
  }
}
