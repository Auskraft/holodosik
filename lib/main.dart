import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/theme/theme_cubit.dart';
import 'core/di/locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Контент рисуется под системными барами; отступы берёт SafeArea.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(
    BlocProvider(create: (_) => ThemeCubit(), child: const HolodosikApp()),
  );
}
