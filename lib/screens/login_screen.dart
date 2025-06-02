import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/main_button.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await AuthEvent.signIn(
        context,
        UserLoginInfo(
          email: _usernameController.text,
          password: _passwordController.text,
        ),
      );

      if (!AuthEvent.isLoggedIn(context)) {
        MessageToUser.showMessage(
          context,
          AppLocalizations.of(context)!.loginScreen_failed,
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacementNamed(context, '/loading');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: Center(
        child: StandardDialogBox(
          title: localization.loginScreen_title,
          subtitle: localization.loginScreen_subtitle,
          icon: Icons.person,
          maxWidth: 360,
          content: StandardDialogBox.buildStandardForm(
            formKey: _formKey,
            child: Column(
              children: [
                StandardDialogBox.buildStandardFormField(
                  controller: _usernameController,
                  label: localization.loginScreen_emailLabel,
                  hint: localization.loginScreen_emailHint,
                  prefixIcon: Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return localization.loginScreen_emailRequired;
                    } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                      return localization.loginScreen_emailInvalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                StandardDialogBox.buildStandardFormField(
                  controller: _passwordController,
                  label: localization.loginScreen_passwordLabel,
                  obscureText: true,
                  prefixIcon: Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localization.loginScreen_passwordRequired;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  ),
                SizedBox(height: 10),
                MainButton(
                  text: localization.loginScreen_signInButton,
                  onPressed: () async {
                    if (!_isLoading) {
                      await _submitForm();
                    }
                  },
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(localization.loginScreen_noAccount),
                    TextButton(
                      onPressed:
                          () => Navigator.pushReplacementNamed(
                            context,
                            '/signup',
                          ),
                      child: Text(
                        localization.loginScreen_createAccount,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [],
        ),
      ),
    );
  }
}
