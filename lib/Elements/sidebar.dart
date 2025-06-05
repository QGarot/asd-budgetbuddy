import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _showUserMenu = false;
  bool _isUserHovered = false;
  bool _isLogoutHovered = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final userData = context.watch<DataCubit>().state;

    return Container(
      width: LayoutConstants.getSidebarWidth(context),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () {
                final cubit = context.read<SidebarCubit>();
                cubit.selectPage(SidebarPage.dashboard);
              },
              child: Text(
                loc.sidebar_appTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _SidebarItem(
            icon: Icons.dashboard,
            label: loc.sidebar_dashboard,
            page: SidebarPage.dashboard,
          ),
          _SidebarItem(
            icon: Icons.show_chart,
            label: loc.sidebar_progress,
            page: SidebarPage.progress,
          ),
          _SidebarItem(
            icon: Icons.pie_chart,
            label: loc.sidebar_statistics,
            page: SidebarPage.statistics,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400], thickness: 1),
          const SizedBox(height: 12),
          _SidebarItem(
            icon: Icons.settings,
            label: loc.sidebar_settings,
            page: SidebarPage.settings,
          ),
          _SidebarItem(
            icon: Icons.help_outline,
            label: loc.sidebar_help,
            page: SidebarPage.help,
          ),
          const Spacer(),
          if (userData != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildUserMenu(context, userData.username, userData.email),
            ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, String username, String email) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showUserMenu)
          MouseRegion(
            onEnter: (_) => setState(() => _isLogoutHovered = true),
            onExit: (_) => setState(() => _isLogoutHovered = false),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await AuthEvent.signOut(context);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation1, animation2) =>
                                const LoginScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );
                  },
                  borderRadius: UIConstants.borderRadius,
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isLogoutHovered
                              ? AppColors.primaryFaint
                              : Colors.white,
                      borderRadius: UIConstants.borderRadius,
                      boxShadow: UIConstants.standardShadow,
                    ),
                    child: Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Icon(
                            Icons.logout,
                            size: 18,
                            color:
                                _isLogoutHovered
                                    ? AppColors.primaryColor
                                    : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          loc.sidebar_logout,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        MouseRegion(
          onEnter: (_) => setState(() => _isUserHovered = true),
          onExit: (_) => setState(() => _isUserHovered = false),
          child: InkWell(
            onTap: () => setState(() => _showUserMenu = !_showUserMenu),
            borderRadius: UIConstants.borderRadius,
            child: Container(
              decoration: BoxDecoration(
                color:
                    (_showUserMenu || _isUserHovered)
                        ? AppColors.primaryFaint
                        : Colors.transparent,
                borderRadius: UIConstants.borderRadius,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryColor,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Icon(
                      _showUserMenu
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final SidebarPage page;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.page,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final current = context.watch<SidebarCubit>().state;
    final isSelected = widget.page == current;

    final bgColor =
        isSelected
            ? AppColors.primaryColor
            : (_isHovered ? AppColors.primaryFaint : Colors.transparent);

    final textColor = isSelected ? Colors.white : Colors.black;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: UIConstants.borderRadius,
          boxShadow: isSelected ? UIConstants.standardShadow : null,
        ),
        child: ListTile(
          leading: Directionality(
            textDirection: TextDirection.ltr,
            child: Icon(widget.icon, size: 20, color: textColor),
          ),
          title: Text(widget.label, style: TextStyle(color: textColor)),
          shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadius),
          onTap: () {
            final cubit = context.read<SidebarCubit>();
            cubit.selectPage(widget.page);
          },
        ),
      ),
    );
  }
}
