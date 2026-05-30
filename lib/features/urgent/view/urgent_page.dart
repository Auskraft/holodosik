import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';

/// «Срочное» — приоритетная полка. Наполним списком из запасов на след. этапе.
class UrgentPage extends StatelessWidget {
  const UrgentPage({super.key});

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
            child: Text(l.urgentTitle, style: context.textTheme.headlineMedium),
          ),
          Expanded(
            child: EmptyState(
              icon: Icons.local_fire_department_outlined,
              title: l.urgentEmpty,
              hint: l.comingSoon,
            ),
          ),
        ],
      ),
    );
  }
}
