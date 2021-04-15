// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/form_config.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:smart_select/smart_select.dart';

class PointPickerField extends StatefulWidget {
	final TextEditingController controller;
	final UICurrency pickedCurrency;
	final List<UICurrency> currencies;
	final bool loading;
	final bool canBeEmpty;
	final int minPoints;
	final int maxPoints;

	final Function(String) pointValueSetter;
	final Function(UICurrency) pointCurrencySetter;

	final String labelValueText;
	final String helperValueText;
	final String labelCurrencyText;

	PointPickerField({
		@required this.controller,
		@required UICurrency pickedCurrency,
		@required List<UICurrency> currencies,
		this.loading = false,
		this.canBeEmpty = true,
		this.minPoints = 0,
		this.maxPoints = 1000000,
		this.pointValueSetter,
		this.pointCurrencySetter,
		@required this.labelValueText,
		@required this.helperValueText,
		@required this.labelCurrencyText
	}) : pickedCurrency = pickedCurrency ?? UICurrency(type: CurrencyType.diamond), currencies = currencies ?? [];

	@override
  State<StatefulWidget> createState() => new _PointPickerFieldState();

}

class _PointPickerFieldState extends State<PointPickerField> {
	UICurrency pickedCurrency;

	@override
  void initState() {
		pickedCurrency = UICurrency.from(widget.pickedCurrency);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
		return SmartSelect<UICurrency>.single(
			tileBuilder: (context, selectState) {
				return Padding(
					padding: EdgeInsets.only(top: 0.0, bottom: 0.0, left: 20.0, right: 16.0),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: TextFormField(
									controller: widget.controller,
									decoration: AppFormProperties.textFieldDecoration(Icons.star).copyWith(
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
											FilteringTextInputFormatter.digitsOnly
									],
									onChanged: (val) => widget.pointValueSetter(val)
								)
							),
							GestureDetector(
								onTap: () {
									if(!widget.loading && widget.currencies.length > 1) {
										FocusManager.instance.primaryFocus.unfocus();
										selectState.showModal();
									}
								},
								child: Tooltip(
									message: widget.labelCurrencyText,
									child: Row(
										children: <Widget>[
											Padding(
												padding: EdgeInsets.only(left: 10.0, top: 4.0),
												child: CircleAvatar(
													child: SvgPicture.asset(getIconPath(selectState.selected.value != null ? selectState.selected.value.type : CurrencyType.diamond), width: 28, fit: BoxFit.cover),
													backgroundColor: AppColors.currencyColor[selectState.selected.value != null ? selectState.selected.value.type : CurrencyType.diamond].withAlpha(50)
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
			selectedValue: widget.pickedCurrency,
			choiceItems: [
				for(UICurrency element in widget.currencies)
					S2Choice(
						title: element.getName(context),
						value: element
					)
			],
			choiceBuilder: (context, selectState, choice) {
				return RadioListTile<UICurrency>(
					value: choice.value,
					groupValue: pickedCurrency,
					onChanged: (val) {
						choice.select(!choice.selected);
						setState(() {
							pickedCurrency = choice.value;
						});
					},
					title: Row(
						children: [
							Padding(
								padding: EdgeInsets.only(right: 6.0),
								child: SvgPicture.asset(getIconPath(choice.value.type), width: 30, fit: BoxFit.cover)
							),
							Text(choice.value.getName(context), style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.currencyColor[choice.value.type]))
						]
					)
				);
			},
			modalType: S2ModalType.bottomSheet,
			modalConfig: S2ModalConfig(
				useConfirm: true
			),
			modalConfirmBuilder: (context, callback) => ButtonSheetConfirmButton(callback: () => callback),
			onChange: (selected) => widget.pointCurrencySetter(selected.value)
		);
  }

  String getIconPath(CurrencyType type) => AssetType.currencies.getPath(type.index);
}
