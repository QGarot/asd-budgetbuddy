import 'package:flutter/widgets.dart';

class LayoutConstants {
  //static const double mainWidthProcent = 0.5;
  //static const double mainHeightProcent = 0.65;
  static const double sidebarWidthProcent = 0.2;
  static const double contentMaxWidthProcent = 0.7;
  static const double tabViewHeightProcent = 0.58;
  static const double cardWidthProcent = 0.2;
  static const double cardWidthSpacingProcent = 0.015;
  static const double spacing = 16;

  static const double minSidebarWidth = 200.0;
  static const double maxSidebarWidth = 300.0;
  static const double minContentWidth = 500.0;
  static const double minCardWidth = 220.0;

  //Sidebar
  static double getSidebarWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width * sidebarWidthProcent <
        minSidebarWidth) {
      return minSidebarWidth;
    }
    if (MediaQuery.of(context).size.width * sidebarWidthProcent >
        maxSidebarWidth) {
      return maxSidebarWidth;
    } else {
      return MediaQuery.of(context).size.width * sidebarWidthProcent;
    }
  }

  //Content
  static double getContentMaxWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width * contentMaxWidthProcent <
        minContentWidth) {
      return minContentWidth;
    } else {
      return MediaQuery.of(context).size.width * contentMaxWidthProcent;
    }
  }

  //Card width
  static double getCardWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width * cardWidthProcent < minCardWidth) {
      return minCardWidth;
    } else {
      return MediaQuery.of(context).size.width * cardWidthProcent;
    }
  }

  //Sized Boxes Numbers mean Pixel
  static const double spaceOverDashboard = 16;
  static const double spacebetweenDashboardBudgetOverview = 24;
  static const double spacebetweenBudgetOverviewTabView = 24;
  static const double spaceAfterTabview = 40;
}
