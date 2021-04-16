// @dart = 2.10
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/app_paths.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:smart_select/smart_select.dart';

enum IconPickerType { reward, badge }

class IconPickerField extends StatefulWidget {
	final String title;
	final String groupTextKey;
	final Function(int) callback;
	final int value;
	final IconPickerType type;

	IconPickerField({
		@required this.title,
		@required this.groupTextKey,
		@required this.callback,
		@required this.value,
		this.type = IconPickerType.reward
	});

	IconPickerField.reward({
		String title,
		String groupTextKey,
		Function(int) callback,
		int value
	}) : this(title: title, groupTextKey: groupTextKey, callback: callback, value: value, type: IconPickerType.reward);

	IconPickerField.badge({
		String title,
		String groupTextKey,
		Function(int) callback,
		int value
	}) : this(title: title, groupTextKey: groupTextKey, callback: callback, value: value, type: IconPickerType.badge);

	@override
  State<StatefulWidget> createState() => new _IconPickerFieldState();

}

class _IconPickerFieldState extends State<IconPickerField> {

  @override
  Widget build(BuildContext context) {
		bool isRewardType = widget.type == IconPickerType.reward;

		return Padding(
			padding: EdgeInsets.symmetric(vertical: 10.0),
			child: SmartSelect<int>.single(
				title: widget.title,
				selectedValue: widget.value,
				choiceItems: List.generate((isRewardType ? rewardIcons : badgeIcons).length, (index) {
						final String name = AppLocales.of(context).translate(
							widget.groupTextKey + '.${(isRewardType ? rewardIcons : badgeIcons)[index].label.toString().split('.').last}'
						);
						return S2Choice(
							title: name,
							group: name,
							value: index
						);
					}
				),
				tileBuilder: (context, selectState) {
					return S2Tile.fromState(
						selectState,
						isTwoLine: true,
						leading: SvgPicture.asset(getPicturePath(isRewardType, widget.value), height: 74.0),
					);
				},
				groupEnabled: true,
				choiceConfig: S2ChoiceConfig(
					overscrollColor: Colors.teal,
					runSpacing: 10.0,
					spacing: 10.0,
					layout: S2ChoiceLayout.wrap
				),
				choiceBuilder: (context, selectState, choice) {
					return Badge(
						badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
						badgeColor: Colors.green,
						animationType: BadgeAnimationType.scale,
						showBadge: choice.selected != null ? choice.selected : false,
						child: GestureDetector(
							onTap: () => choice.select(!choice.selected),
							child: SvgPicture.asset(getPicturePath(isRewardType, choice.value), height: 64.0)
						)
					);
				},
				modalType: S2ModalType.bottomSheet,
				modalConfig: S2ModalConfig(
					useConfirm: true
				),
				modalConfirmBuilder: (context, selectState) {
					return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
				},
				onChange: (selected) => widget.callback(selected.value)
			)
		);
  }

  String getPicturePath(bool isAwardType, int value) => isAwardType ? AssetType.rewards.getPath(value) : AssetType.badges.getPath(value);
}
