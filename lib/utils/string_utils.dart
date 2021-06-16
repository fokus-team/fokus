import 'package:flutter/material.dart';
import '../model/ui/child_card_model.dart';
import '../services/app_locales.dart';

String displayJoin(List<String> parts, String andWord) {
	var tail = '';
	if (parts.length >= 2) {
		tail = '${parts[parts.length - 2]} $andWord ${parts[parts.length - 1]}';
		parts = parts.sublist(0, parts.length - 2);
	}
	if (parts.isNotEmpty && tail.isNotEmpty)
		tail = ', $tail';
	return parts.join(', ') + tail;
}

String getChildCardSubtitle(BuildContext context, ChildCardModel childCard) {
	var key = 'page.caregiverSection.panel.content';
	if (childCard.hasActivePlan)
		return AppLocales.of(context).translate('$key.activePlan');
	return AppLocales.of(context).translate('$key.todayPlans', {'NUM_PLANS': '${childCard.todayPlanCount}'});
}
