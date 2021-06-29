import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../logic/caregiver/auth/sign_in/caregiver_sign_in_cubit.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';
import '../../utils/auth_field_validators.dart';
import '../../utils/ui/form_config.dart';
import '../../utils/ui/snackbar_utils.dart';
import '../buttons/popup_menu_list.dart';
import 'auth_button.dart';
import 'auth_widgets.dart';
import 'new_auth_input_field.dart';

class CaregiverSignInForm extends StatefulWidget {
  final String? initialEmail;

  CaregiverSignInForm(this.initialEmail);

  @override
  _CaregiverSignInFormState createState() => _CaregiverSignInFormState();
}

class _CaregiverSignInFormState extends State<CaregiverSignInForm> {
  // TODO extract from sign in page
  static const String _pageKey = 'page.loginSection.caregiverSignIn';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CaregiverSignInCubit, StatefulState<CaregiverSignInData>>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: AuthGroup(
            title: AppLocales.of(context).translate('$_pageKey.logInTitle'),
            hint: AppLocales.of(context).translate('$_pageKey.logInHint'),
            isLoading: state.beingSubmitted,
            action: PopupMenuList(
              lightTheme: true,
              customIcon: Icons.settings,
              items: _buildAdditionalLoginSettings(context)
            ),
            content: Column(
              children: <Widget>[
                AuthInputField(
                  controller: _emailController,
                  validator: validateEmail,
                  labelKey: 'authentication.email',
                  icon: Icons.email,
                  inputType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email]
                ),
                AuthInputField(
                  controller: _passwordController,
                  validator: validatePassword,
                  labelKey: 'authentication.password',
                  icon: Icons.lock,
                  hideInput: true,
                  autofillHints: [AutofillHints.password]
                ),
                AuthButton(
                  button: UIButton.ofType(
                    ButtonType.signIn,
                    () {
                      if (_formKey.currentState!.validate())
                        BlocProvider.of<CaregiverSignInCubit>(context).signInWithEmail(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                    },
                    Colors.teal
                  )
                ),
                AuthDivider(),
                AuthButton.google(
                  button: UIButton(
                    'authentication.googleSignIn',
                    () => BlocProvider.of<CaregiverSignInCubit>(context).signInWithGoogle()
                  )
                )
              ]
            )
          ),
        );
      }
    );
  }

  List<UIButton> _buildAdditionalLoginSettings(BuildContext context) {
    return [
      UIButton(
        '$_pageKey.resetPassword',
        () async {
          if (await context.read<CaregiverSignInCubit>().resetPassword(_emailController.text))
            showSuccessSnackbar(context, '$_pageKey.resetEmailSent');
        },
        null,
        Icons.settings_backup_restore
      ),
      UIButton(
        '$_pageKey.resetVerificationEmail',
        () async {
          if (!_formKey.currentState!.validate())
            return;
          var result = await context.read<CaregiverSignInCubit>().resendVerificationEmail(
            email: _emailController.text,
            password: _passwordController.text,
          );
          if (result == VerificationAttemptOutcome.emailSent)
            showSuccessSnackbar(context, 'authentication.emailVerificationSent');
          else if (result == VerificationAttemptOutcome.accountAlreadyVerified)
            showInfoSnackbar(context, 'authentication.error.accountAlreadyVerified');
        },
        null,
        Icons.mark_email_read
      ),
      UIButton(
        'actions.contactUs',
        () => FlutterEmailSender.send(emailBlueprint),
        null,
        Icons.contact_mail
      ),
    ];
  }
}
