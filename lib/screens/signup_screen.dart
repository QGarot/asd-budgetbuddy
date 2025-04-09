import 'package:budgetbuddy/Elements/main_button.dart';
import 'package:budgetbuddy/Elements/message_to_user.dart';
import 'package:budgetbuddy/Elements/standard_dialog_box.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';
import 'package:flutter/material.dart';

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
        MessageToUser.showMessage(context, "Account creation failed!");
        setState(() => _isLoading = false);
        return;
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        MessageToUser.showMessage(context, "Account created successfully!");
        Navigator.pushReplacementNamed(context, '/loading');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StandardDialogBox(
          title: "Create Account",
          subtitle: "Enter your details to create a new account",
          icon: Icons.person,
          maxWidth: 360,
          content: StandardDialogBox.buildStandardForm(
            formKey: _formKey,
            child: Column(
              children: [
                StandardDialogBox.buildStandardFormField(
                  controller: _usernameController,
                  label: "Username",
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Username is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StandardDialogBox.buildStandardFormField(
                  controller: _emailController,
                  label: "Email",
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    } else if (!RegExp(r"\S+@\S+\.\S+").hasMatch(value)) {
                      return "Email is invalid";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                StandardDialogBox.buildStandardFormField(
                  controller: _passwordController,
                  label: "Password",
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    } else if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                MainButton(
                  text: "Sign up",
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
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        "Login",
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
