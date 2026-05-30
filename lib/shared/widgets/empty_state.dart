import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/context_theme_x.dart';

/// Дружелюбное пустое состояние: иконка, заголовок и необязательная подсказка.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
  });

  final IconData icon;
  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.textFaint),
            const SizedBox(height: AppSpacing.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
            if (hint != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: colors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
