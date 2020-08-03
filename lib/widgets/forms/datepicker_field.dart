import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';

class DatePickerField extends StatefulWidget {
	final String labelText;
	final String errorText;
	final String helperText;
	final IconData icon;
	final DateTime dateField;
	final TextEditingController dateController;
	final bool canBeEmpty;
	final DateTime rangeFromDate;
	final DateTime rangeToDate;
	final DateTime initialDate;
	final Function callback;

	DatePickerField({
		@required this.labelText,
		@required this.dateController,
		@required this.dateField,
		@required this.callback,
		this.errorText,
		this.helperText,
		this.icon = Icons.event,
		this.canBeEmpty = true,
		this.rangeFromDate,
		this.rangeToDate,
		this.initialDate
	});

	@override
  State<StatefulWidget> createState() => new _DatePickerFieldState();

}

class _DatePickerFieldState extends State<DatePickerField> {
	bool _showClearButton = false;

	Future<DateTime> _selectDate(BuildContext context) async {
    return await showDatePicker(
			locale: AppLocales.of(context).locale,
			context: context,
			helpText: widget.labelText,
			fieldLabelText: widget.labelText,
			firstDate: widget.rangeFromDate != null ? widget.rangeFromDate : DateTime.now(),
			lastDate: widget.rangeToDate != null ? widget.rangeToDate : DateTime(2100),
			initialDate: widget.initialDate != null ? widget.initialDate : DateTime.now()
		);
  }

  @override
  void initState() {
    super.initState();
    widget.dateController.addListener(() {
      setState(() => {_showClearButton = widget.dateController.text.isNotEmpty});
    });
  }

  @override
  Widget build(BuildContext context) {
		String errorMessage = (widget.errorText != null) ? widget.errorText : AppLocales.of(context).translate('alert.genericEmptyValue');
		return Stack(
			alignment: Alignment.topRight,
			children: [
				TextFormField(
					onTap: () => widget.callback(_selectDate(context), widget.dateField, widget.dateController),
					controller: widget.dateController,
					readOnly: true,
					decoration: InputDecoration(
						icon: Padding(padding: EdgeInsets.all(8.0), child: Icon(widget.icon)),
						contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
						border: OutlineInputBorder(),
						labelText: widget.labelText,
						hintText: AppLocales.of(context).translate('actions.tapToSelect'),
						helperText: widget.helperText
					),
					validator: (value) {
						return widget.canBeEmpty ? null : (value.isEmpty ? errorMessage : null);
					}
				),
				if(_showClearButton)
					IconButton(
						icon: Icon(Icons.clear),
						onPressed: () {
							FocusScope.of(context).requestFocus(FocusNode());
							widget.dateController.clear();
						}
					)
			]
		);
	}

}
