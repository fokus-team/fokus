import 'package:flutter/material.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/icon_sets.dart';

enum AssetPathType { flutter, drawable }

extension GraphicAssetPaths on AssetType {
	String get category => const {
		AssetType.avatars: 'avatar',
		AssetType.rewards: 'reward',
		AssetType.badges: 'badge',
		AssetType.currencies: 'currency',
	}[this]!;

	String getPath(int? index, [AssetPathType pathType = AssetPathType.flutter]) {
		String assetId;
		if (this == AssetType.currencies) {
			if (index == null)
				index = 0;
			assetId = CurrencyType.values[index].name;
		} else
			assetId = index == null || graphicAssets[this]![index] == null ? 'default' : graphicAssets[this]![index]!.filename;
		if (pathType == AssetPathType.drawable)
			return '${category}_${assetId.replaceAll(RegExp('-'), '_')}';
		else
			return 'assets/image/$category/$assetId.svg';
	}
}

String helpPagePath(BuildContext context, String helpPage) {
	return 'assets/help/${AppLocales.of(context).locale!.languageCode}/$helpPage.md';
}
