import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:formz/formz.dart';

import 'package:fokus/model/ui/button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class AuthenticationSubmitButton<Bloc extends Cubit<State>, State extends FormzState> extends StatelessWidget {
	final UIButton button;

  const AuthenticationSubmitButton({this.button});

  @override
  Widget build(BuildContext context) {
	  return BlocBuilder<Bloc, State>(
		  buildWhen: (previous, current) => previous.status != current.status,
		  builder: (context, state) {
			  return RaisedButton(
				  child: Text(AppLocales.of(context).translate(button.type.key)),
				  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
				  onPressed: state.status.isValidated ? () => button.action(context) : null,
			  );
		  },
	  );
  }
}
