import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fokus/logic/caregiver/caregiver_currencies_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/snackbar_utils.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/stateful_bloc_builder.dart';

class CaregiverCurrenciesPage extends StatefulWidget {
	@override
	_CaregiverCurrenciesPageState createState() => new _CaregiverCurrenciesPageState();
}

class _CaregiverCurrenciesPageState extends State<CaregiverCurrenciesPage> {
	static const String _pageKey = 'page.caregiverSection.currencies';
	late GlobalKey<FormState>? currenciesKey;
	late Map<CurrencyType, String> currencyList;
	bool isDataChanged = false;

	@override
  void initState() {
		currencyList = Map<CurrencyType, String>();
		currencyList[CurrencyType.emerald] = '';
		currencyList[CurrencyType.ruby] = '';
		currencyList[CurrencyType.amethyst] = '';
		currenciesKey = GlobalKey<FormState>();
    super.initState();
  }
	
	@override
  void dispose() {
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return SimpleStatefulBlocBuilder<CaregiverCurrenciesCubit, CaregiverCurrenciesState>(
			listener: (context, state) {
				if (state.loaded) {
					for(Currency currency in (state as CaregiverCurrenciesState).currencies) {
						if (currency.type != CurrencyType.diamond)
							currencyList[currency.type!] = currency.name!;
					}
				}
				if (state.submitted)
					showSuccessSnackbar(context, '$_pageKey.content.currenciesUpdatedText');
			},
			popConfig: SubmitPopConfig.onSubmitted(),
	    builder: (context, state) {
				return WillPopScope(
					onWillPop: () async {
						bool? ret = await showExitFormDialog(context, true, isDataChanged);
						if(ret == null || !ret) return false;
						else return true;
					},
					child: Scaffold(
						appBar: AppBar(
							backgroundColor: AppColors.formColor,
							title: Text(AppLocales.of(context).translate('$_pageKey.header.title')),
							actions: <Widget>[
								HelpIconButton(helpPage: 'currencies')
							]
						),
						body: Stack(
							children: [
								Positioned.fill(
									bottom: AppBoxProperties.standardBottomNavHeight,
									child: Form(
										key: currenciesKey,
										child: Material(
											child: buildCurrenciesFields(context)
										)
									)
								),
								Positioned.fill(
									top: null,
									child: buildBottomNavigation(context)
								)
							]
						)
					)
				);
			}
		);
	}

	void saveCurrencies(BuildContext context) {
		if(currenciesKey!.currentState!.validate()) {
			BlocProvider.of<CaregiverCurrenciesCubit>(context).updateCurrencies(
				currencyList.entries
					.where((element) => element.value.isNotEmpty)
					.map((currency) => Currency(type: currency.key, name: currency.value))
					.toList()
			);
		}
	}

	Widget buildBottomNavigation(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
			decoration: AppBoxProperties.elevatedContainer,
			height: AppBoxProperties.standardBottomNavHeight,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.end,
				children: <Widget>[
					SizedBox.shrink(),
					TextButton(
						onPressed: () => saveCurrencies(context),
						child: Text(
							AppLocales.of(context).translate('$_pageKey.content.saveCurrenciesButton'),
							style: Theme.of(context).textTheme.button?.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget buildCurrencyTile(CurrencyType type, String title) {
		return ListTile(
			title: Text(title.isEmpty ? AppLocales.of(context).translate('$_pageKey.content.currencyNotUsed') : title),
			subtitle: Text(AppLocales.of(context).translate('$_pageKey.content.currencies.${type.toString().split('.')[1]}')),
			leading: Padding(
				padding: EdgeInsets.only(left: 10.0, top: 4.0),
				child: CircleAvatar(
					child: SvgPicture.asset(AssetType.currencies.getPath(type.index), width: 28, fit: BoxFit.cover),
					backgroundColor: AppColors.currencyColor[type]?.withAlpha(50)
				)
			),
			enabled: title.isNotEmpty,
			trailing: type != CurrencyType.diamond ?
				Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						IconButton(
							icon: Icon(Icons.edit, color: Colors.grey[600]),
							onPressed: () => {
								showCurrencyEditDialog(
									context,
									(val) => setState(() {
										currencyList[type] = val!;
										isDataChanged = true;
									}),
									initialValue: currencyList[type]
								)
							},
							tooltip: AppLocales.of(context).translate('actions.edit'),
							splashRadius: 28
						),
						if(title.isNotEmpty)
							IconButton(
								icon: Icon(Icons.remove_circle, color: Colors.grey[600]),
								onPressed: () => {
									showBasicDialog(
										context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('actions.clear'),
											content: AppLocales.of(context).translate('$_pageKey.content.clearCurrencyText'),
											confirmAction: () => setState(() {
												currencyList[type] = '';
												isDataChanged = true;
												Navigator.of(context).pop();
											})
										)
									)
								},
								tooltip: AppLocales.of(context).translate('actions.clear'),
								splashRadius: 28
							)
					]
				)
				: SizedBox.shrink()
		);
	}

	Widget buildCurrenciesFields(BuildContext context) {
		return ListView(
			shrinkWrap: true,
			children: <Widget>[
				Padding(
					padding: EdgeInsets.all(AppBoxProperties.screenEdgePadding),
					child: Text(AppLocales.of(context).translate('$_pageKey.content.generalHint'))
				),
				buildCurrencyTile(CurrencyType.diamond, AppLocales.of(context).translate('points')),
				Divider(),
				...currencyList.entries.map((currency) => buildCurrencyTile(currency.key, currency.value)).toList()
			]
		);
	}
	
}
