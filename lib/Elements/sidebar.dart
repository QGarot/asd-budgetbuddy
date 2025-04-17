import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/bloc/Auth/auth_event.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:budgetbuddy/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _showUserMenu = false;

  @override
  Widget build(BuildContext context) {
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
                "BudgetBuddy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const _SidebarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            page: SidebarPage.dashboard,
          ),
          const _SidebarItem(
            icon: Icons.show_chart,
            label: "Progress",
            page: SidebarPage.progress,
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[400], thickness: 1),
          const SizedBox(height: 12),
          const _SidebarItem(
            icon: Icons.settings,
            label: "Settings",
            page: SidebarPage.settings,
          ),
          const _SidebarItem(
            icon: Icons.help_outline,
            label: "Help",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showUserMenu)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await AuthEvent.signOut(context);
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
                    color: Colors.white,
                    borderRadius: UIConstants.borderRadius,
                    boxShadow: UIConstants.standardShadow,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        InkWell(
          onTap: () => setState(() => _showUserMenu = !_showUserMenu),
          borderRadius: UIConstants.borderRadius,
          child: Container(
            decoration: BoxDecoration(
              color:
                  _showUserMenu ? AppColors.primaryFaint : Colors.transparent,
              borderRadius: UIConstants.borderRadius,
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryColor,
                  child: Icon(Icons.person, color: Colors.white),
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  _showUserMenu
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: AppColors.primaryColor,
                ),
              ],
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
          leading: Icon(widget.icon, size: 20, color: textColor),
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
