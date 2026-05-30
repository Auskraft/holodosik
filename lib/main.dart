import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/di/locator.dart';
import 'domain/repositories/stock_repository.dart';
import 'features/inventory/bloc/inventory_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Контент рисуется под системными барами; отступы берёт SafeArea.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  setupLocator();
  runApp(
    BlocProvider(
      create: (_) => InventoryCubit(locator<StockRepository>()),
      child: const HolodosikApp(),
    ),
  );
}
