import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/Elements/add_budget_dialog.dart';
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

                Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 24,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Budget Dashboard",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Manage and track your spending",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF9E9E9E),
                                  fontWeight: FontWeight.w400,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 24,
                      top: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: UIConstants.standardShadow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AddBudgetDialog(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Create Budget"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
