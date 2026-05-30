import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:holodosik/app/app.dart';
import 'package:holodosik/app/theme/theme_cubit.dart';

void main() {
  testWidgets('Приложение запускается и показывает бренд', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ThemeCubit(),
        child: const HolodosikApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('холодос'), findsOneWidget);
    expect(find.text('Использовать'), findsOneWidget);
  });
}
