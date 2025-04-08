import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/Elements/sidebar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          const Material(elevation: 8, child: Sidebar()),
          Padding(
            padding: const EdgeInsets.only(left: 240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: UIConstants.borderRadius,
                    boxShadow: UIConstants.standardShadow,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Text(
                    "Budget Dashboard",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(64, 48, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Budget Dashboard",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "Manage and track your spending",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w400,
                          height: 1.1,
                        ),
                      ),
                      // Place Additional widgets here
                      ElevatedButton(
                        onPressed: () {
                          //Logout from firebase
                          AuthEvent.signOut(context);
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: Text("Logout"),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
                // Logic for changing screens here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
