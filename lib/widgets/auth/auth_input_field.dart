import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../logic/common/formz_state.dart';
import '../../services/app_locales.dart';
import '../../utils/ui/theme_config.dart';

class AuthenticationInputField<Bloc extends Cubit<State>, State extends FormzState> extends StatefulWidget {
	final List<dynamic> Function(State) getErrorKey;
	final FormzInput Function(State) getField;
	final Function(Bloc, String) changedAction;

	final String labelKey;
	final TextInputType inputType;
	final bool hideInput;
	final IconData icon;
	final bool clearable;
	final bool disabled;
	final List<String>? autofillHints;

  AuthenticationInputField({
		required this.getField,
		required this.changedAction,
		required this.labelKey,
		required this.getErrorKey,
		this.inputType = TextInputType.text,
		this.hideInput = false,
		this.icon = Icons.edit,
	  this.clearable = false,
	  this.disabled = false,
	  this.autofillHints
	});

  @override
  _AuthenticationInputFieldState<Bloc, State> createState() => _AuthenticationInputFieldState<Bloc, State>();
}

class _AuthenticationInputFieldState<Bloc extends Cubit<CubitState>, CubitState extends FormzState> extends State<AuthenticationInputField<Bloc, CubitState>> {
	TextEditingController? _controller;

  @override
  Widget build(BuildContext context) {
	  return BlocBuilder<Bloc, CubitState>(
		  buildWhen: (previous, current) => widget.getField(previous).status != widget.getField(current).status,
		  builder: (context, state) {
			  _controller ??= TextEditingController(text: widget.getField(state).value)..addListener(() {
			    return widget.changedAction(BlocProvider.of<Bloc>(context), _controller!.value.text);
			  });
			  return Padding(
			    padding: const EdgeInsets.all(8.0),
			    child: TextField(
				    enabled: !widget.disabled,
					  controller: _controller,
					  keyboardType: widget.inputType,
					  obscureText: widget.hideInput,
						style: widget.disabled ? TextStyle(color: AppColors.mediumTextColor) : null,
						decoration: InputDecoration(
							icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(widget.icon)),
							contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
							border: OutlineInputBorder(),
							labelText: AppLocales.of(context).translate(widget.labelKey),
						  errorText: widget.getField(state).invalid ? Function.apply(AppLocales.of(context).translate, widget.getErrorKey(state)) : null,
							suffixIcon: widget.clearable ? IconButton(
								onPressed: () => _controller?.clear(),
								icon: Icon(Icons.clear),
								tooltip: AppLocales.instance.translate('actions.clear'),
							) : null,
						),
						autofillHints: widget.autofillHints,
			    ),
			  );
		  },
	  );
  }
}
