import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../services/app_locales.dart';
import '../../utils/ui/theme_config.dart';

class AuthInputField extends StatefulWidget {
  final FormFieldValidator<String>? validator;
	final String labelKey;
	final TextInputType inputType;
	final bool hideInput;
	final IconData icon;
	final bool clearable;
	final bool disabled;
	final List<String>? autofillHints;
  final TextEditingController controller;

  AuthInputField({
    required this.controller,
    required this.validator,
		required this.labelKey,
		this.inputType = TextInputType.text,
		this.hideInput = false,
		this.icon = Icons.edit,
	  this.clearable = false,
	  this.disabled = false,
	  this.autofillHints
	});

  @override
  _AuthInputFieldState createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {

  @override
  Widget build(BuildContext context) {
	  return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        validator: widget.validator,
        enabled: !widget.disabled,
        controller: widget.controller,
        keyboardType: widget.inputType,
        obscureText: widget.hideInput,
        style: widget.disabled ? TextStyle(color: AppColors.mediumTextColor) : null,
        decoration: InputDecoration(
          icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(widget.icon)),
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          border: OutlineInputBorder(),
          labelText: AppLocales.of(context).translate(widget.labelKey),
          suffixIcon: widget.clearable ? IconButton(
            onPressed: () => widget.controller.clear(),
            icon: Icon(Icons.clear),
            tooltip: AppLocales.instance.translate('actions.clear'),
          ) : null,
        ),
        autofillHints: widget.autofillHints,
      ),
    );
  }
}
