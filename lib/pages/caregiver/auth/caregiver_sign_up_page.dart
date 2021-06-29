import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../../logic/caregiver/auth/sign_up/caregiver_sign_up_cubit.dart';
import '../../../model/ui/external_url.dart';
import '../../../model/ui/ui_button.dart';
import '../../../services/app_locales.dart';
import '../../../services/exception/auth_exceptions.dart';
import '../../../utils/auth_field_validators.dart';
import '../../../utils/ui/snackbar_utils.dart';
import '../../../utils/ui/theme_config.dart';
import '../../../widgets/auth/auth_button.dart';
import '../../../widgets/auth/auth_widgets.dart';
import '../../../widgets/auth/new_auth_input_field.dart';

class CaregiverSignUpPage extends StatefulWidget {
	static const String _pageKey = 'page.loginSection.caregiverSignUp';

  @override
  _CaregiverSignUpPageState createState() => _CaregiverSignUpPageState();
}

class _CaregiverSignUpPageState extends State<CaregiverSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  void Function()? _validateAgreement;
  bool? _agreementChecked;

  @override
  Widget build(BuildContext context) {
	  return Scaffold(
		  body: SafeArea(
			  child: BlocListener<CaregiverSignUpCubit, StatefulState<CaregiverSignUpData>>(
				  listener: (context, state) async {
					  if (state.submitFailed && (state.data!.signInError != null || state.data!.signUpError != null))
							showFailSnackbar(context, state.data!.signUpError?.key ?? state.data!.signInError!.key);
					  else if (state.submitted && state.data!.authMethod == AuthMethod.email && await context.read<CaregiverSignUpCubit>().verificationEnforced()) {
							TextInput.finishAutofillContext(shouldSave: true);
							showSuccessSnackbar(context, 'authentication.emailVerificationSent');
						}
				  },
					child: ListView(
						padding: EdgeInsets.symmetric(vertical: AppBoxProperties.screenEdgePadding),
						shrinkWrap: true,
						children: [
							_buildSignUpForm(context),
							AuthFloatingButton(
								icon: Icons.arrow_back,
								action: () => Navigator.of(context).pop(),
								text: AppLocales.of(context).translate('page.loginSection.backToLoginPage')
							)
						]
					)
			  )
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return BlocBuilder<CaregiverSignUpCubit, StatefulState<CaregiverSignUpData>>(
		  bloc: BlocProvider.of<CaregiverSignUpCubit>(context),
			builder: (context, state) {
				return Form(
          key: _formKey,
				  child: AuthGroup(
				  	title: AppLocales.of(context).translate('${CaregiverSignUpPage._pageKey}.registerTitle'),
				  	hint: AppLocales.of(context).translate('${CaregiverSignUpPage._pageKey}.registerHint'),
				  	isLoading: state.beingSubmitted,
				  	content: Column(
				  		children: <Widget>[
				  			AuthInputField(
                  controller: _nameController,
				  				validator: validateName,
				  				labelKey: 'authentication.name',
				  				icon: Icons.person,
				  				inputType: TextInputType.name,
				  				autofillHints: [AutofillHints.givenName],
				  			),
				  			AuthInputField(
                  controller: _emailController,
				  				validator: validateEmail,
				  				labelKey: 'authentication.email',
				  				icon: Icons.email,
				  				inputType: TextInputType.emailAddress,
				  				autofillHints: [AutofillHints.email],
				  			),
				  			AuthInputField(
                  controller: _passwordController,
				  				validator: (value) => validatePassword(value, fullValidation: true),
				  				labelKey: 'authentication.password',
				  				icon: Icons.lock,
				  				hideInput: true,
				  				autofillHints: [AutofillHints.newPassword],
				  			),
				  			AuthInputField(
                  controller: _repeatPasswordController,
				  				validator: (value) => validateConfirmPassword(value: value, original: _passwordController.text),
				  				labelKey: 'authentication.confirmPassword',
				  				icon: Icons.lock,
				  				hideInput: true,
				  				autofillHints: [AutofillHints.newPassword],
				  			),
				  			_buildAgreementCheckbox(context),
				  			AuthButton(
				  				button: UIButton.ofType(
				  					ButtonType.signUp,
				  					() {
				  					  if (_formKey.currentState!.validate())
                      BlocProvider.of<CaregiverSignUpCubit>(context).signUpWithEmail(
                        email: _emailController.text,
                        name: _nameController.text,
                        password: _passwordController.text,
                      );
				  					},
				  					Colors.teal
				  				),
				  			),
				  			AuthDivider(),
				  			AuthButton.google(
                  disabled: !(_agreementChecked ?? false),
				  				button: UIButton(
				  					'authentication.googleSignUp',
				  					() {
				  					  if (!(_agreementChecked ?? false)) {
				  					    if (_validateAgreement != null) _validateAgreement!();
				  					    return;
                      }
				  					  BlocProvider.of<CaregiverSignUpCubit>(context).signInWithGoogle();
				  					}
				  				)
				  			)
				  		]
				  	)
				  ),
				);
			}
		);
	}

	Widget _buildAgreementCheckbox(BuildContext context) {
		return FormField<bool>(
      initialValue: false,
      validator: validateAgreement,
      builder: (FormFieldState<bool> state) {
        _validateAgreement = state.validate;
        var linkTextStyle = TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        );
        return InkWell(
          onTap: () {
            state.didChange(!state.value!);
            setState(() => _agreementChecked = state.value!);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Checkbox(
                        value: state.value!,
                        onChanged: (bool? newValue) {
                          if(newValue != null && newValue != state.value!) {
                            state.didChange(newValue);
                            setState(() => _agreementChecked = newValue);
                          }
                        }
                      )
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${AppLocales.of(context).translate('${CaregiverSignUpPage._pageKey}.agreement')} ',
                          style: Theme.of(context).textTheme.bodyText2,
                          children: [
                            TextSpan(
                              text: AppLocales.of(context).translate('${CaregiverSignUpPage._pageKey}.termsOfUse'),
                              style: linkTextStyle,
                              recognizer: TapGestureRecognizer()..onTap = () {
                                ExternalURL.termsOfUse.openBrowserPage(context);
                              }
                            ),
                            TextSpan(
                              text: ' ${AppLocales.of(context).translate('and')} ',
                              style: Theme.of(context).textTheme.bodyText2
                            ),
                            TextSpan(
                              text: AppLocales.of(context).translate('${CaregiverSignUpPage._pageKey}.privacyPolicy'),
                              style: linkTextStyle,
                              recognizer: TapGestureRecognizer()..onTap = () {
                                ExternalURL.privacyPolicy.openBrowserPage(context);
                              }
                            ),
                            TextSpan(
                              text: '.',
                              style: Theme.of(context).textTheme.bodyText2
                            )
                          ]
                        )
                      )
                    )
                  ]
                ),
                if(state.hasError)
                  Padding(
                    padding: EdgeInsets.only(left: 68.0, top: 2.0, bottom: 4.0),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                        fontSize: 12.0,
                      )
                    )
                  )
              ]
            )
          )
        );
      }
    );
	}
}
