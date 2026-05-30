import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';

/// Хранит выбранную тему. Персист (БД/настройки) подключим в слое настроек.
class ThemeCubit extends Cubit<AppThemeId> {
  ThemeCubit() : super(AppThemeId.light);

  void select(AppThemeId id) {
    if (id != state) emit(id);
  }
}
