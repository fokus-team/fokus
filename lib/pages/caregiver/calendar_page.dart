import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/utils/calendar_utils.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_bar_buttons.dart';
import 'package:intl/intl.dart';
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

class _CaregiverCalendarPageState extends State<CaregiverCalendarPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.calendar';
	AnimationController _animationController;
	CalendarController _calendarController;

	List<UIChild> _selectedChildren = [];

	final Duration _animationDuration = Duration(milliseconds: 250);
	final Color notAssignedPlanMarkerColor = Colors.grey[400];


	@override
	void initState() {
		super.initState();
		_calendarController = CalendarController();
		_animationController = AnimationController(vsync: this, duration: _animationDuration);
		_animationController.forward();
	}

	@override
	void dispose() {
		_calendarController.dispose();
		_animationController.dispose();
		super.dispose();
	}

	Color _getChildColor(Map<UIChild, bool> children, Mongo.ObjectId childID) {
		int childIndex = children.keys.toList().indexWhere((element) => element.id == childID);
		return (childIndex != -1) ? AppColors.markerColors[childIndex % AppColors.markerColors.length] : Colors.cyan;
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
                    buildWhen: (oldState, newState) => oldState.children != newState.children,
									  builder: (context, state) {
										  if (state.children == null) {
											  context.bloc<CalendarCubit>().loadInitialData();
											  return _buildChildPicker(loading: true);
										  }
									    return _buildChildPicker(children: state.children);
									  },
								  ),
								)
							)
						)
					),
					AppSegments(
						segments: [
							Padding(
								padding: EdgeInsets.symmetric(horizontal: AppBoxProperties.screenEdgePadding),
								child: BlocBuilder<CalendarCubit, CalendarState>(
									builder: (context, state) {
										return _buildCalendar(state.events, state.children);
									},
								)
							),
							Padding(
								padding: EdgeInsets.only(top: AppBoxProperties.sectionPadding),
								child: _buildPlanList()
							)
						]
					)
				]
			)
		);
	}

	Widget _buildPlanList(){
		return BlocBuilder<CalendarCubit, CalendarState>(
			builder: (context, state) {
				return Segment(
					title: '$_pageKey.content.plansOnDateTitle',
					titleArgs: {'DATE': DateFormat.yMd(Localizations.localeOf(context).toString()).format(state.day).toString()},
					noElementsMessage: '$_pageKey.content.noPlansOnDateTitle',
					noElementsIcon: Icons.description,
					elements: [
						if(state.events != null && state.events[state.day] != null)
							for(UIPlan plan in state.events[state.day])
								ItemCard(
									title: plan.name,
									onTapped: () => Navigator.pushNamed(context, AppPage.planDetails.name, arguments: plan.id),
									subtitle: AppLocales.of(context).translate(
										'$_pageKey.content.${plan.assignedTo.isNotEmpty ? 'planAssignedToSubtitle' : 'planNotAssignedToSubtitle'}'
									),
									isActive: plan.assignedTo.isNotEmpty,
									chips: plan.assignedTo.isNotEmpty ? plan.assignedTo.map((childID) {
										var child = state.children.keys.firstWhere((element) => element.id == childID, orElse: () => null);
										return child != null ? AttributeChip(
											content: child.name,
											color: _getChildColor(state.children, childID)
										) : SizedBox.shrink();
									}).toList() : []
								)
					]
				);
			}
		);
	}

	TableCalendar _buildCalendar(Map<Date, List<UIPlan>> events, Map<UIChild, bool> children) {
	  return buildCalendar(
			controller: _calendarController, 
			context: context,
			events: events,
			onDaySelected: onDayChanged,
			onCalendarCreated: onCalendarCreated,
			onVisibleDaysChanged: onMonthChanged,
			builders: CalendarBuilders(
				selectedDayBuilder: (context, date, _) =>
          FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: buildTableCalendarCell(date, AppColors.caregiverBackgroundColor, isCellSelected: true)
					),
        todayDayBuilder: (context, date, _) => buildTableCalendarCell(date, Colors.transparent),
				markersBuilder: (context, date, events, holidays) {
					final markers = <Widget>[];
					if (events.isNotEmpty) {
						Set<Color> childrenMarkers = {};
						events.forEach((plan) {
							if(plan.assignedTo.isEmpty)
								childrenMarkers.add(notAssignedPlanMarkerColor);
							else
								plan.assignedTo.forEach((childID) {
									if(_selectedChildren.isEmpty || _selectedChildren.firstWhere((element) => element.id == childID, orElse: () => null) != null)
										childrenMarkers.add(_getChildColor(children, childID));
							});
						});
						markers.add(buildMarker(colorSet: childrenMarkers));
					}
					return markers;
				}
			)
		);
	}

	void onDayChanged(DateTime day, List<dynamic> events) {
		context.bloc<CalendarCubit>().dayChanged(Date.fromDate(day));
		_animationController.forward(from: 0.0);
	}

	void onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
		context.bloc<CalendarCubit>().monthChanged(Date.fromDate(_calendarController.focusedDay));
	}

	void onMonthChanged(DateTime first, DateTime last, CalendarFormat format) {
		onCalendarCreated(first, last, format);
		_calendarController.setSelectedDay(Date.fromDate(Utils.firstDayOfMonth(_calendarController.focusedDay)));
	}

	SmartSelect<UIChild> _buildChildPicker({Map<UIChild, bool> children = const {}, bool loading = false}) {
	  return SmartSelect<UIChild>.multiple(
	    title: AppLocales.of(context).translate('$_pageKey.header.filterPlansTitle'),
	    value: _selectedChildren,
	    builder: (context, state, callback) {
	      return InkWell(
	        onTap: () {
	          FocusManager.instance.primaryFocus.unfocus();
	          if(!loading)
							callback(context);
	        },
	        child: Column(
	          crossAxisAlignment: CrossAxisAlignment.start,
	          children: [
	            ListTile(
	              title: Text(AppLocales.of(context).translate(state.values.isNotEmpty ?
									'$_pageKey.header.showPlansForTitle'
									: '$_pageKey.header.filterPlansTitle'
								)),
	              trailing: loading ?
									Padding(
										padding: EdgeInsets.only(left: 2.0, top: 2.0),
										child: SizedBox(
											child: CircularProgressIndicator(
												valueColor: AlwaysStoppedAnimation<Color>(Colors.black45),
												strokeWidth: 1.5,
											),
											height: 16.0,
											width: 16.0,
										)
									)
									: Icon(Icons.keyboard_arrow_right, color: Colors.grey)
	            ),
							AnimatedSwitcher(
								duration: _animationDuration,
								switchInCurve: Curves.easeIn,
								switchOutCurve: Curves.easeOut,
								transitionBuilder: (child, animation) {
									return SizeTransition(
										sizeFactor: animation,
										axis: Axis.vertical,
										child: child
									);
								},
								child: state.values.isNotEmpty ?
									Padding(
										padding: EdgeInsets.symmetric(horizontal: 12.0).copyWith(bottom: 10.0),
										child: Wrap(
											spacing: 4.0,
											runSpacing: 4.0,
											children: state.values.map((child) {
												return AttributeChip(
													content: child.name,
													color: _getChildColor(children, child.id)
												);
											}).toList(),
										)
									) : SizedBox.shrink()
							)
	          ]
	        )
	      );
	    },
	    options: SmartSelectOption.listFrom(
	      source: children.keys.toList(),
	      value: (index, item) => item,
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
	          graphicType: AssetType.avatars,
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
				trailing: ButtonSheetBarButtons(
					buttons: [
						UIButton('actions.confirm', () { Navigator.pop(context); }, Colors.green, Icons.done)
					],
				)
			),
	    onChange: (val) {
				setState(() { _selectedChildren = val; });
	      Map<UIChild, bool> filter = {};
				for(var child in children.keys)
					filter[child] = val.contains(child);
	      context.bloc<CalendarCubit>().childFilterChanged(filter);
	    }
	  );
	}
}
