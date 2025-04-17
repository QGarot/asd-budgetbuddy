import 'package:flutter_bloc/flutter_bloc.dart';

enum SidebarPage { dashboard, progress, settings, help, showExpense }

class SidebarCubit extends Cubit<SidebarPage> {
  SidebarCubit() : super(SidebarPage.dashboard);

  void selectPage(SidebarPage page) => emit(page);
}
