import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isUserHovered = false;

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<DataCubit>().state;

    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              onTap: () {
                final cubit = context.read<SidebarCubit>();
                final current = cubit.state;
                cubit.selectPage(SidebarPage.dashboard);
                if (current == SidebarPage.dashboard) {
                  // Optional: trigger refresh logic here
                }
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
              child: MouseRegion(
                onEnter: (_) => setState(() => _isUserHovered = true),
                onExit: (_) => setState(() => _isUserHovered = false),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        _isUserHovered
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
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userData.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
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
            final current = cubit.state;
            cubit.selectPage(widget.page);

            if (current == widget.page) {
              // Optional refresh logic
            }
          },
        ),
      ),
    );
  }
}
