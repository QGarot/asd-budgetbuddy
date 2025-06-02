import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/Elements/main_button.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await AuthEvent.signUp(
        context,
        UserRegistrationInfo(
          email: _emailController.text,
          userName: _usernameController.text,
          password: _passwordController.text,
        ),
      );

      if (!AuthEvent.isLoggedIn(context)) {
        MessageToUser.showMessage(
          context,
          AppLocalizations.of(context)!.signupScreen_failed,
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacementNamed(context, '/loading');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: Center(
        child: StandardDialogBox(
          title: loc.signupScreen_title,
          subtitle: loc.signupScreen_subtitle,
          icon: Icons.person,
          maxWidth: 360,
          content: StandardDialogBox.buildStandardForm(
            formKey: _formKey,
            child: Column(
              children: [
                StandardDialogBox.buildStandardFormField(
                  controller: _usernameController,
                  label: loc.signupScreen_usernameLabel,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.signupScreen_usernameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StandardDialogBox.buildStandardFormField(
                  controller: _emailController,
                  label: loc.signupScreen_emailLabel,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return loc.signupScreen_emailRequired;
                    } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                      return loc.signupScreen_emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StandardDialogBox.buildStandardFormField(
                  controller: _passwordController,
                  label: loc.signupScreen_passwordLabel,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return loc.signupScreen_passwordRequired;
                    } else if (value.length < 8) {
                      return loc.signupScreen_passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MainButton(
                  text: loc.signupScreen_button,
                  onPressed: () async {
                    if (!_isLoading) {
                      await _submitForm();
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(loc.signupScreen_hasAccount),
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        loc.signupScreen_login,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: const [],
        ),
      ),
    );
  }
}
