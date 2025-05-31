import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/Elements/progress_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final double maxHeightTabView =
        MediaQuery.of(context).size.height *
        LayoutConstants.tabViewHeightProcent;

    return Scaffold(
      backgroundColor: AppColors.backgroundColorHomescreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderBar(title: loc.progressScreen_header),

          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: LayoutConstants.getContentMaxWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: LayoutConstants.spaceOverDashboard,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.progressScreen_title,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.progressScreen_subtitle,
                                  style: const TextStyle(
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

                      const SizedBox(
                        height:
                            LayoutConstants.spacebetweenDashboardBudgetOverview,
                      ),

                      SizedBox(
                        height: maxHeightTabView,
                        child: const ProgressTabView(),
                      ),

                      const SizedBox(height: LayoutConstants.spaceAfterTabview),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
