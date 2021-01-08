import 'package:flutter/material.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/form_config.dart';

class DatePickerField extends StatefulWidget {
	final String labelText;
	final String errorText;
	final String helperText;
	final IconData icon;
	final Function dateSetter;
	final TextEditingController dateController;
	final bool canBeEmpty;
	final DateSpan<Date> rangeDate;
	final Date initialDate;
	final Function callback;

	DatePickerField({
		@required this.labelText,
		@required this.dateController,
		@required this.dateSetter,
		@required this.callback,
		this.errorText,
		this.helperText,
		this.icon = Icons.event,
		this.canBeEmpty = true,
		this.rangeDate,
		this.initialDate
	});

	@override
  State<StatefulWidget> createState() => new _DatePickerFieldState();

}

class _DatePickerFieldState extends State<DatePickerField> {
	bool _showClearButton = false;

	Future<DateTime> _selectDate(BuildContext context) async {
		DateTime initial = DateTime.now();
		if(widget.dateController.text != '') {
			initial = DateTime.tryParse(widget.dateController.text);
		} else if(widget.rangeDate != null) {
			if(widget.rangeDate.from != null) {
				initial = widget.rangeDate.from;
			} else if(widget.rangeDate.to != null) {
				initial = widget.rangeDate.to;
			}
		}

    return await showDatePicker(
			locale: AppLocales.of(context).locale,
			context: context,
			helpText: widget.labelText,
			fieldLabelText: widget.labelText,
			firstDate: (widget.rangeDate != null && widget.rangeDate.from != null) ? widget.rangeDate.from : DateTime(2020),
			lastDate: (widget.rangeDate != null && widget.rangeDate.to != null) ? widget.rangeDate.to : DateTime(2100),
			initialDate: initial
		);
  }

  @override
  void initState() {
    super.initState();
		_showClearButton = widget.dateController.text.isNotEmpty;
    widget.dateController.addListener(() {
      setState(() => { _showClearButton = widget.dateController.text.isNotEmpty });
    });
  }

  @override
  Widget build(BuildContext context) {
		String errorMessage = (widget.errorText != null) ?
			widget.errorText :
			AppLocales.of(context).translate('alert.genericEmptyValue');
		
		return Padding(
			padding: EdgeInsets.only(top: 0, bottom: 0, left: 20.0, right: 20.0),
			child: Stack(
				alignment: Alignment.topRight,
				children: [
					TextFormField(
						onTap: () => _selectDate(context).then((value) => widget.callback(value, widget.dateSetter, widget.dateController)),
						controller: widget.dateController,
						readOnly: true,
						decoration: AppFormProperties.textFieldDecoration(widget.icon).copyWith(
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
								widget.callback(null, widget.dateSetter, widget.dateController);
							}
						)
				]
			)
		);
	}

}
