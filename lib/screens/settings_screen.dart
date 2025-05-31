import 'package:budgetbuddy/AppData/app_colors.dart';
import 'package:budgetbuddy/AppData/layout_constants.dart';
import 'package:budgetbuddy/AppData/app_text_styles.dart';
import 'package:budgetbuddy/AppData/ui_constants.dart';
import 'package:budgetbuddy/Elements/header_bar.dart';
import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:budgetbuddy/bloc/Locale/locale_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedLocale;
  bool _isDirty = false;
  String? _hoveredLocale;

  final List<Map<String, String>> _availableLocales = [
    {'code': 'en', 'label': 'English', 'subtitle': 'English'},
    {'code': 'de', 'label': 'Deutsch', 'subtitle': 'German'},
    {'code': 'ar', 'label': 'العربية', 'subtitle': 'Arabic'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocale = context.read<LocaleCubit>().state.languageCode;
  }

  void _onSelectLocale(String code) {
    if (code != _selectedLocale) {
      setState(() {
        _selectedLocale = code;
        _isDirty = true;
      });
    }
  }

  Future<void> _onSave() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && _selectedLocale != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'settings': {'locale': _selectedLocale},
      }, SetOptions(merge: true));

      context.read<LocaleCubit>().setLocale(Locale(_selectedLocale!));

      final currentUserData = context.read<DataCubit>().getFirebaseUserData();
      if (currentUserData != null) {
        context.read<DataCubit>().patchUserLocale(_selectedLocale!);
      }

      setState(() {
        _isDirty = false;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsScreen_languageSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundColorHomescreen,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderBar(title: loc.settingsScreen_title),
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
                      const SizedBox(height: LayoutConstants.spaceOverDashboard),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.settingsScreen_title, style: AppTextStyles.dashboardTitle),
                            const SizedBox(height: 4),
                            Text(loc.settingsScreen_subtitle, style: AppTextStyles.dashboardSubtitle),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLanguageSection(loc),
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

  Widget _buildLanguageSection(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: UIConstants.standardShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: Colors.black87),
              const SizedBox(width: 12),
              Text(
                loc.settingsScreen_languageTitle,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(loc.settingsScreen_languageSubtitle),
          const SizedBox(height: 20),
          ..._availableLocales.map((lang) {
            final isSelected = _selectedLocale == lang['code'];
            final isHovered = _hoveredLocale == lang['code'];
            final borderColor = isSelected || isHovered ? AppColors.primaryColor : Colors.grey.shade300;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredLocale = lang['code']),
                onExit: (_) => setState(() => _hoveredLocale = null),
                child: InkWell(
                  onTap: () => _onSelectLocale(lang['code']!),
                  borderRadius: UIConstants.borderRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryFaint : Colors.white,
                      borderRadius: UIConstants.borderRadius,
                      border: Border.all(color: borderColor, width: 1.4),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: UIConstants.borderRadius),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                        child: Text(lang['code']!.toUpperCase()),
                      ),
                      title: Text(lang['label']!),
                      subtitle: Text(lang['subtitle']!),
                      trailing: isSelected ? Icon(Icons.check, color: AppColors.primaryColor) : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _isDirty ? _onSave : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(loc.settingsScreen_saveLanguagePreference),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
