import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/theme/theme_cubit.dart';
import 'core/di/locator.dart';

void main() {
  setupLocator();
  runApp(
    BlocProvider(create: (_) => ThemeCubit(), child: const HolodosikApp()),
  );
}
