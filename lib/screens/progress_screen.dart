import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/Elements/dashboard_header.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:budgetbuddy/Elements/progress_tab_view.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.progressScreen_title;
    final subtitle = AppLocalizations.of(context)!.progressScreen_subtitle;
    final double maxHeightTabView =
        MediaQuery.of(context).size.height *
        LayoutConstants.tabViewHeightProcent;

    return Scaffold(
      backgroundColor: AppColors.backgroundColorHomescreen,
      appBar: HeaderBar(
        title: AppLocalizations.of(context)!.progressScreen_header,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

                      DashboardHeader(
                        title: title,
                        subtitle: subtitle,
                        buttonText: "",
                        onPressed: () {},
                        showButton: false,
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
