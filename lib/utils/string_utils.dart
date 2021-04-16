import 'package:flutter/material.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';

String displayJoin(List<String> parts, String andWord) {
	String tail = '';
	if (parts.length >= 2) {
		tail = '${parts[parts.length - 2]} $andWord ${parts[parts.length - 1]}';
		parts = parts.sublist(0, parts.length - 2);
	}
	if (parts.length > 0 && tail.isNotEmpty)
		tail = ', $tail';
	return parts.join(', ') + tail;
}

String getChildCardSubtitle(BuildContext context, UIChild child) {
	String key = 'page.caregiverSection.panel.content';
	if (child.hasActivePlan!)
		return AppLocales.of(context).translate('$key.activePlan');
	return AppLocales.of(context).translate('$key.todayPlans', {'NUM_PLANS': '${child.todayPlanCount}'});
}
