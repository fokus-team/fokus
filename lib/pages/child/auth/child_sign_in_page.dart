import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/widgets/buttons/bottom_sheet_confirm_button.dart';
import 'package:formz/formz.dart';
import 'package:smart_select/smart_select.dart';

import 'package:fokus/logic/child/auth/sign_up/child_sign_up_cubit.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:fokus/widgets/auth/auth_button.dart';
import 'package:fokus/widgets/auth/auth_input_field.dart';
import 'package:fokus/model/ui/auth/user_code.dart';
import 'package:fokus/model/ui/auth/name.dart';
import 'package:fokus/widgets/auth/auth_widgets.dart';
import 'package:fokus/logic/child/auth/sign_in/child_sign_in_cubit.dart';

class ChildSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignIn';
	
  @override
  Widget build(BuildContext context) {
  	var activeUser = BlocProvider.of<AuthenticationBloc>(context).state.user;
	  return Scaffold(
		  body: SafeArea(
			  child: BlocListener<ChildSignUpCubit, ChildSignUpState>(
				  listener: (context, state) {
					  if (state.status.isSubmissionSuccess && activeUser != null)
						  Navigator.of(context).pop();
				  },
				  child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							_buildForms(context, activeUser),
							AuthFloatingButton(
								icon: Icons.arrow_back,
								action: () => Navigator.of(context).pop(),
								text: AppLocales.of(context).translate('page.loginSection.backTo${activeUser != null ? 'App' : 'LoginPage'}')
							)
						]
					)
			  ),
		  ),
	  );
  }

  Widget _buildForms(BuildContext context, UIUser? activeUser) {
	  return AuthGroup(
			title: AppLocales.of(context).translate('$_pageKey.profileAddTitle'),
			hint: AppLocales.of(context).translate('$_pageKey.profileAddHint${activeUser != null ? 'SignedIn' : ''}'),
			content: ListView(
				shrinkWrap: true,
				children: <Widget>[
					if (activeUser == null)
						...[
							AuthenticationInputField<ChildSignInCubit, ChildSignInState>(
								getField: (state) => state.childCode, // temp
								changedAction: (cubit, value) => cubit.childCodeChanged(value), // temp
								labelKey: '$_pageKey.childCode',
								icon: Icons.screen_lock_portrait,
								getErrorKey: (state) => [state.childCode.error!.key], // temp
							),
							AuthButton(
								button: UIButton(
									'$_pageKey.addProfile',
									() => BlocProvider.of<ChildSignInCubit>(context).signInNewChild(),
									Colors.orange
								)
							),
							AuthDivider(),
							AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
								getField: (state) => state.caregiverCode,
								changedAction: (cubit, value) => cubit.caregiverCodeChanged(value),
								labelKey: '$_pageKey.caregiverCode',
								icon: Icons.phonelink_lock,
								getErrorKey: (state) => [state.caregiverCode.error!.key],
								disabled: activeUser != null,
							),
						],
					AuthenticationInputField<ChildSignUpCubit, ChildSignUpState>(
						getField: (state) => state.name,
						changedAction: (cubit, value) => cubit.nameChanged(value),
						labelKey: 'authentication.name',
						icon: Icons.edit,
						getErrorKey: (state) => [state.name.error!.key],
					),
					_buildAvatarPicker(context),
					AuthButton(
						button: UIButton(
							'$_pageKey.createNewProfile',
							() => BlocProvider.of<ChildSignUpCubit>(context).signUpFormSubmitted(),
							Colors.orange
						)
					)
				]
			)
		);
	}

	Widget _buildAvatarPicker(BuildContext context) {
		return BlocBuilder<ChildSignUpCubit, ChildSignUpState>(
			buildWhen: (oldState, newState) => oldState.avatar != newState.avatar || oldState.takenAvatars != newState.takenAvatars,
			bloc: BlocProvider.of<ChildSignUpCubit>(context),
			builder: (context, state) {
				return Padding(
					padding: EdgeInsets.symmetric(vertical: 10.0),
					child: SmartSelect<int>.single(
						title: AppLocales.of(context).translate('authentication.avatar'),
						tileBuilder: (context, selectState) {
							bool isInvalid = (state.status == FormzStatus.invalid && state.avatar == null);
							return ListTile(
								leading: SizedBox(
									width: 56.0,
									height: 64.0,
									child: state.avatar != null ? AppAvatar(state.avatar) : AppAvatar.blank()
								),
								title: Text(AppLocales.of(context).translate('authentication.avatar')),
								subtitle: Text(isInvalid ? 
										AppLocales.of(context).translate('authentication.error.avatarEmpty')
										: (state.avatar == null) ?
											AppLocales.of(context).translate('actions.tapToSelect')
											: AppLocales.of(context).translate('actions.selected'),
									style: TextStyle(color: isInvalid ? Theme.of(context).errorColor : Colors.grey),
									overflow: TextOverflow.ellipsis,
									maxLines: 1
								),
								trailing: Icon(Icons.keyboard_arrow_right, color: Colors.grey),
								onTap: () => selectState.showModal()
							);
						},
						selectedValue: state.avatar,
						choiceItems: List.generate(childAvatars.length, (index) {
							final String name = AppLocales.of(context).translate('$_pageKey.avatarGroups.${childAvatars[index]!.label.toString().split('.').last}');
							return S2Choice(
								title: name,
								group: name,
								value: index,
								disabled: state.takenAvatars.contains(index)
							);
						}),
						choiceConfig: S2ChoiceConfig(
							overscrollColor: Colors.teal,
							runSpacing: 10.0,
							spacing: 10.0,
							layout: S2ChoiceLayout.wrap
						),
						choiceBuilder: (context, selectState, choice) {
							return GestureDetector(
								onTap: choice.disabled ? null : () => choice.select!(!choice.selected),
								child: AppAvatar(choice.value, checked: choice.selected, disabled: choice.disabled)
							);
						},
						modalType: S2ModalType.bottomSheet,
						modalConfig: S2ModalConfig(
							useConfirm: true
						),
						modalConfirmBuilder: (context, selectState) {
							return ButtonSheetConfirmButton(callback: () => selectState.closeModal(confirmed: true));
						},
						onChange: (selected) {
							FocusManager.instance.primaryFocus!.unfocus();
							BlocProvider.of<ChildSignUpCubit>(context).avatarChanged(selected.value!);
						}
					)
				);
			}
		);
	}

}
