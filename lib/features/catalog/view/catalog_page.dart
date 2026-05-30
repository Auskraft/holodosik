import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';

/// «Справочник» — все известные продукты. Подключим к данным на след. этапе.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Text(l.catalogTitle, style: context.textTheme.headlineMedium),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.menu_book_outlined,
              title: l.comingSoon,
            ),
          ),
        ],
      ),
    );
  }
}
