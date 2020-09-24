import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/logic/caregiver_currencies_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/dialog_utils.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/dialogs/general_dialog.dart';
import 'package:fokus/widgets/general/app_loader.dart';

import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class CaregiverCurrenciesPage extends StatefulWidget {
	@override
	_CaregiverCurrenciesPageState createState() => new _CaregiverCurrenciesPageState();
}

class _CaregiverCurrenciesPageState extends State<CaregiverCurrenciesPage> {
	static const String _pageKey = 'page.caregiverSection.currencies';
	GlobalKey<FormState> currenciesKey;
	Map<CurrencyType, String> currencyList;
	bool isDataChanged = false;

	@override
  void initState() {
		currencyList = Map<CurrencyType, String>();
		currencyList[CurrencyType.emerald] = null;
		currencyList[CurrencyType.ruby] = null;
		currencyList[CurrencyType.amethyst] = null;
		currenciesKey = GlobalKey<FormState>();
    super.initState();
  }
	
	@override
  void dispose() {
		super.dispose();
	}

  @override
  Widget build(BuildContext context) {
		return BlocConsumer<CaregiverCurrenciesCubit, CaregiverCurrenciesState>(
			listener: (context, state) {
				if (state is CaregiverCurrenciesLoadSuccess) {
					for(UICurrency currency in state.currencies)
						currencyList[currency.type] = currency.title;
				}
				if (state is CaregiverCurrenciesSubmissionSuccess) {
					Navigator.of(context).pop();
					// visual feedback
					// showSuccessSnackbar(context, '$_pageKey.content.currenciesUpdatedText');
				}
			},
	    builder: (context, state) {
				if(state is CaregiverCurrenciesInitial) {
					context.bloc<CaregiverCurrenciesCubit>().doLoadData();
				}
				return WillPopScope(
					onWillPop: () => showExitFormDialog(context, true, isDataChanged),
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
									child: state is CaregiverCurrenciesLoadSuccess || state is CaregiverCurrenciesSubmissionSuccess ? Form(
										key: currenciesKey,
										child: Material(
											child: buildCurrenciesFields(context, state.currencies)
										)
									) : AppLoader()
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
		if(currenciesKey.currentState.validate()) {
			context.bloc<CaregiverCurrenciesCubit>().updateCurrencies(
				currencyList.entries
					.where((element) => element.value != null)
					.map((currency) => UICurrency(type: currency.key, title: currency.value))
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
					FlatButton(
						onPressed: () => saveCurrencies(context),
						child: Text(
							AppLocales.of(context).translate('$_pageKey.content.saveCurrenciesButton'),
							style: Theme.of(context).textTheme.button.copyWith(color: AppColors.mainBackgroundColor)
						)
					)
				]
			)
		);
	}

	Widget buildCurrencyTile(CurrencyType type, String title) {
		return ListTile(
			title: Text(title == null ? AppLocales.of(context).translate('$_pageKey.content.currencyNotUsed') : title),
			subtitle: Text(AppLocales.of(context).translate('$_pageKey.content.currencies.${type.toString().split('.')[1]}')),
			leading: Padding(
				padding: EdgeInsets.only(left: 10.0, top: 4.0),
				child: CircleAvatar(
					child: SvgPicture.asset(currencySvgPath(type), width: 28, fit: BoxFit.cover),
					backgroundColor: AppColors.currencyColor[type].withAlpha(50)
				)
			),
			enabled: title != null,
			trailing: type != CurrencyType.diamond ?
				Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						IconButton(
							icon: Icon(Icons.edit),
							onPressed: () => {
								showCurrencyEditDialog(
									context,
									(val) => setState(() {
										currencyList[type] = val;
										isDataChanged = true;
									}),
									initialValue: currencyList[type]
								)
							},
							tooltip: AppLocales.of(context).translate('actions.edit'),
							splashRadius: 28
						),
						if(title != null)
							IconButton(
								icon: Icon(Icons.remove_circle),
								onPressed: () => {
									showBasicDialog(
										context,
										GeneralDialog.confirm(
											title: AppLocales.of(context).translate('actions.clear'),
											content: AppLocales.of(context).translate('$_pageKey.content.clearCurrencyText'),
											confirmAction: () => setState(() {
												currencyList[type] = null;
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

	Widget buildCurrenciesFields(BuildContext context, List<UICurrency> currencies) {
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
