import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/auth/formz_state.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:formz/formz.dart';
import 'package:fokus/model/ui/ui_button.dart';

class AuthenticationSubmitButton<Bloc extends Cubit<State>, State extends FormzState> extends StatelessWidget {
	final UIButton button;

  const AuthenticationSubmitButton({this.button});

  @override
  Widget build(BuildContext context) {
	  return BlocBuilder<Bloc, State>(
		  buildWhen: (previous, current) => previous.status != current.status,
		  builder: (context, state) {
			  return AuthButton(
					button: UIButton(
						button.textKey,
						state.status.isValidated ? () => button.action() : null,
						button.color
					)
				);
		  }
	  );
  }
}
