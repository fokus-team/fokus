import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_select/smart_select.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/logic/calendar_cubit.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/segment.dart';

class CaregiverCalendarPage extends StatefulWidget {
	@override
	_CaregiverCalendarPageState createState() => new _CaregiverCalendarPageState();
}

class _CaregiverCalendarPageState extends State<CaregiverCalendarPage> {
	static const String _pageKey = 'page.caregiverSection.calendar';
	CalendarController _calendarController;
	List<Mongo.ObjectId> filteredChildren;

	List<Color> markerColors = [
		Colors.green,
		Colors.deepPurple,
		Colors.red,
		Colors.orange,
		Colors.purple,
		Colors.pink,
		Colors.teal,
		Colors.brown
	];

	@override
	void initState() {
		super.initState();
		_calendarController = CalendarController();
		filteredChildren = List<Mongo.ObjectId>();
	}

	@override
	void dispose() {
		_calendarController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: Card(
							margin: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 6.0),
							child: InkWell(
								onTap: () => {},
								child: Container(
								  child: BlocBuilder<CalendarCubit, CalendarState>(
									  builder: (context, state) {
										  if (state.children == null) {
											  context.bloc<CalendarCubit>().loadInitialData();
											  return buildChildPicker(loading: true);
										  }
									    return buildChildPicker(children: state.children);
									  },
								  ),
								)
							)
						)
					),
					AppSegments(segments: [
						Padding(
							padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
							child: TableCalendar(
								calendarController: _calendarController,
								locale: AppLocales.of(context).locale.toString(),
								startingDayOfWeek: StartingDayOfWeek.monday,
								initialCalendarFormat: CalendarFormat.month,
								headerStyle: HeaderStyle(
									centerHeaderTitle: true,
									formatButtonVisible: false
								),
								calendarStyle: CalendarStyle(
									selectedColor: AppColors.caregiverBackgroundColor,
									todayColor: Colors.grey,
									markersMaxAmount: 8,
									canEventMarkersOverflow: true
								),
								events: {
									DateTime(2020, 8, 18): [
										"a"
									]
								},
								builders: CalendarBuilders(
									markersBuilder: (context, date, events, holidays) {
										final children = <Widget>[];
										if (events.isNotEmpty) {
											for(var event in events)
												children.add(
													Badge(badgeColor: Colors.green)
												);
										}
										return children;
									}
								)
							)
						)
					])
				]
			)
		);
	}

	SmartSelect<Mongo.ObjectId> buildChildPicker({Map<UIChild, bool> children = const {}, bool loading = false}) {
	  return SmartSelect<Mongo.ObjectId>.multiple(
	    title: 'Filtruj wyświetlane plany',
	    isLoading: loading,
	    value: filteredChildren,
	    builder: (context, state, callback) {
	      int markerIndex = 0;
	      return InkWell(
	        onTap: () {
	          FocusManager.instance.primaryFocus.unfocus();
	          callback(context);
	        },
	        child: Column(
	          crossAxisAlignment: CrossAxisAlignment.start,
	          children: [
	            ListTile(
	              title: Text(state.values.isNotEmpty ? 'Wyświetlaj plany przypisane do' : 'Filtruj wyświetlane plany'),
	              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
	            ),
	            if(state.values.isNotEmpty)
	              Padding(
	                padding: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 10.0),
	                child: Wrap(
	                  spacing: 4.0,
	                  runSpacing: 4.0,
	                  children: state.values.map((id) {
	                    final UIChild child = children.keys.firstWhere((element) => element.id == id);
	                    if(markerIndex == markerColors.length)
	                      markerIndex = 0;
	                    return AttributeChip(
	                      content: child.name,
	                      color: markerColors[markerIndex++],
	                    );
	                  }).toList(),
	                )
	              )
	          ]
	        )
	      );
	    },
	    options: SmartSelectOption.listFrom<Mongo.ObjectId, UIChild>(
	      source: children.keys.toList(),
	      value: (index, item) => item.id,
	      title: (index, item) => item.name,
	      meta: (index, item) => item
	    ),
	    choiceType: SmartSelectChoiceType.chips,
	    choiceConfig: SmartSelectChoiceConfig(
	      builder: (item, checked, onChange) => Theme(
	        data: ThemeData(textTheme: Theme.of(context).textTheme),
	        child: ItemCard(
	          title: item.title,
	          subtitle: AppLocales.of(context).translate(checked ? 'actions.selected' : 'actions.tapToSelect'),
	          graphicType: GraphicAssetType.childAvatars,
	          graphic: item.meta.avatar,
	          graphicShowCheckmark: checked,
	          graphicHeight: 44.0,
	          onTapped: onChange != null ? () => onChange(item.value, !checked) : null,
	          isActive: checked
	        )
	      )
	    ),
	    modalType: SmartSelectModalType.bottomSheet,
	    modalConfig: SmartSelectModalConfig(
	      searchBarHint: AppLocales.of(context).translate('actions.search')
	    ),
	    onChange: (val) => setState(() {
	      FocusManager.instance.primaryFocus.unfocus();
	      filteredChildren.clear();
	      filteredChildren = val;
	    })
	  );
	}
}
