import 'package:budgetbuddy/Elements/main_button.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:flutter/material.dart';

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
        MessageToUser.showMessage(context, "Login failed!");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        MessageToUser.showMessage(context, "Login successful!");
        Navigator.pushReplacementNamed(context, '/loading');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StandardDialogBox(
          title: "Sign In",
          subtitle: "Enter your details to access your account",
          icon: Icons.person,
          maxWidth: 360,
          content: StandardDialogBox.buildStandardForm(
            formKey: _formKey,
            child: Column(
              children: [
                StandardDialogBox.buildStandardFormField(
                  controller: _usernameController,
                  label: "Email",
                  hint: "example@email.com",
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                      return "Email is invalid";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                StandardDialogBox.buildStandardFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 10),
                MainButton(
                  text: "Sign in",
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
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed:
                          () => Navigator.pushReplacementNamed(
                            context,
                            '/signup',
                          ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
