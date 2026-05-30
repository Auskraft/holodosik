import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:holodosik/app/app.dart';
import 'package:holodosik/app/theme/theme_cubit.dart';
import 'package:holodosik/core/di/locator.dart';
import 'package:holodosik/domain/repositories/stock_repository.dart';
import 'package:holodosik/features/inventory/bloc/inventory_cubit.dart';

void main() {
  setUpAll(setupLocator);

  testWidgets('Главный экран показывает бренд и карточки запасов', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (_) => InventoryCubit(locator<StockRepository>()),
          ),
        ],
        child: const HolodosikApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Холодосик'), findsOneWidget);
    expect(find.text('Куриное филе'), findsOneWidget);
    expect(find.text('Использовать'), findsWidgets);
  });
}
