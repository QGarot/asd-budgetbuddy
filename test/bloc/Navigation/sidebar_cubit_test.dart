import 'package:flutter_test/flutter_test.dart';
import 'package:budgetbuddy/bloc/Navigation/sidebar_cubit.dart';

void main() {
  group('SidebarCubit', () {
    test('initial state is dashboard', () {
      final cubit = SidebarCubit();
      expect(cubit.state, SidebarPage.dashboard);
    });

    test('selectPage updates state', () {
      final cubit = SidebarCubit();
      cubit.selectPage(SidebarPage.settings);
      expect(cubit.state, SidebarPage.settings);
    });
  });
}