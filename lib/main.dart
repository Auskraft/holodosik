import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'app/theme/theme_cubit.dart';
import 'core/di/locator.dart';
import 'domain/repositories/stock_repository.dart';
import 'features/inventory/bloc/inventory_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Контент рисуется под системными барами; отступы берёт SafeArea.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => InventoryCubit(locator<StockRepository>())),
      ],
      child: const HolodosikApp(),
    ),
  );
}
