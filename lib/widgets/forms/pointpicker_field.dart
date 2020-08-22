import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/ui_currency.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';
import 'package:smart_select/smart_select.dart';

class PointPickerField extends StatefulWidget {
	final TextEditingController controller;
	final UICurrency pickedCurrency;
	final List<UICurrency> currencies;
	final bool loading;
	final bool canBeEmpty;
	final int minPoints;
	final int maxPoints;

	final Function pointValueSetter;
	final Function pointCurrencySetter;

	final String labelValueText;
	final String helperValueText;
	final String labelCurrencyText;

	PointPickerField({
		@required this.controller,
		@required this.pickedCurrency,
		@required this.currencies,
		this.loading = false,
		this.canBeEmpty = true,
		this.minPoints = 0,
		this.maxPoints = 1000000,
		this.pointValueSetter,
		this.pointCurrencySetter,
		@required this.labelValueText,
		@required this.helperValueText,
		@required this.labelCurrencyText
	});

	@override
  State<StatefulWidget> createState() => new _PointPickerFieldState();

}

class _PointPickerFieldState extends State<PointPickerField> {
  @override
  Widget build(BuildContext context) {
		return SmartSelect<UICurrency>.single(
			isLoading: widget.loading,
			builder: (context, state, function) {
				return Padding(
					padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 20.0, right: 16.0),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: TextFormField(
									controller: widget.controller,
									decoration: InputDecoration(
										icon: Padding(padding: EdgeInsets.all(5.0), child: Icon(Icons.star)),
										contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
										border: OutlineInputBorder(),
										hintText: "0",
										helperMaxLines: 3,
										errorMaxLines: 3,
										helperText: widget.helperValueText,
										labelText: widget.labelValueText,
										suffixIcon: IconButton(
											onPressed: () {
												FocusScope.of(context).requestFocus(FocusNode());
												widget.controller.clear();
												widget.pointValueSetter(null);
											},
											icon: Icon(Icons.clear)
										)
									),
									validator: (value) {
										final range = [widget.minPoints ?? 0, widget.maxPoints ?? 1000000];
										final int numValue = int.tryParse(value);
										return ((!widget.canBeEmpty && numValue == null) || (numValue != null && (numValue < range[0] || numValue > range[1]))) ? 
											AppLocales.of(context).translate('alert.genericRangeOverflowValue', {'A': range[0].toString(), 'B': range[1].toString()})
											: null;
									},
									keyboardType: TextInputType.numberWithOptions(signed: true, decimal: false),
									inputFormatters: <TextInputFormatter>[
											WhitelistingTextInputFormatter.digitsOnly
									],
									onChanged: (val) => widget.pointValueSetter(val)
								)
							),
							GestureDetector(
								onTap: () {
									if(!widget.loading && widget.currencies.length > 1) {
										FocusManager.instance.primaryFocus.unfocus();
										function(context);
									}
								},
								child: Tooltip(
									message: widget.labelCurrencyText,
									child: Row(
										children: <Widget>[
											Padding(
												padding: EdgeInsets.only(left: 10.0, top: 4.0),
												child: CircleAvatar(
													child: SvgPicture.asset(currencySvgPath(state.value.type), width: 28, fit: BoxFit.cover),
													backgroundColor: AppColors.currencyColor[state.value.type].withAlpha(50)
												)
											),
											(widget.loading) ?
												Padding(
													padding: EdgeInsets.only(left: 6.0, top: 2.0),
													child: SizedBox(
														child: CircularProgressIndicator(
															valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
															strokeWidth: 1.5,
														),
														height: 16.0,
														width: 16.0,
													)
												)
												:	(widget.currencies.length > 1) ?
													Padding(
														padding: EdgeInsets.only(left: 4.0, top: 2.0),
														child: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
													)
													: SizedBox.shrink()
										]
									)
								)
							)
						]
					)
				);
			},
			title: widget.labelCurrencyText,
			value: widget.pickedCurrency,
			options: [
				for(UICurrency element in widget.currencies)
					SmartSelectOption(
						title: element.getName(context),
						value: element
					)
			],
			choiceConfig: SmartSelectChoiceConfig(
				builder: (item, checked, onChange) {
					return RadioListTile<UICurrency>(
						value: item.value,
						groupValue: widget.pickedCurrency,
						onChanged: (val) => {onChange(item.value, !checked)},
						title: Row(
							children: [
								Padding(
									padding: EdgeInsets.only(right: 6.0),
									child: SvgPicture.asset(currencySvgPath(item.value.type), width: 30, fit: BoxFit.cover)
								),
								Text(item.value.getName(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.currencyColor[item.value.type]))
							]
						)
					);
				}
			),
			modalType: SmartSelectModalType.bottomSheet,
			modalConfig: SmartSelectModalConfig(
				trailing: ButtonSheetBarButtons(
					buttons: [
						UIButton('actions.confirm', () => { Navigator.pop(context) }, Colors.green, Icons.done)
					],
				)
			),
			onChange: (val) => widget.pointCurrencySetter(val)
		);
  }

}
