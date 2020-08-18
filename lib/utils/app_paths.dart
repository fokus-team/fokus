import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';

String helpPagePath(BuildContext context, String helpPage) {
	return 'assets/help/${AppLocales.of(context).locale.languageCode}/$helpPage.md';
}

String currencySvgPath(CurrencyType currencyType) {
	return 'assets/image/currency/${currencyType.toString().split('.').last}.svg';
}

String childAvatarSvgPath(int avatar) {
	if(graphicAssets[GraphicAssetType.childAvatars][avatar] != null)
		return 'assets/image/avatar/child/${graphicAssets[GraphicAssetType.childAvatars][avatar].filename}.svg';
	else
		return 'assets/image/avatar/default.svg';
}

String awardIconSvgPath(int icon) {
	if(graphicAssets[GraphicAssetType.awardsIcons][icon] != null)
		return 'assets/image/award/${graphicAssets[GraphicAssetType.awardsIcons][icon].filename}.svg';
	else
		return 'assets/image/award/default.svg';
}

String badgeIconSvgPath(int icon) {
	if(graphicAssets[GraphicAssetType.badgeIcons][icon] != null)
		return 'assets/image/badge/${graphicAssets[GraphicAssetType.badgeIcons][icon].filename}.svg';
	else
		return 'assets/image/badge/default.svg';
}
