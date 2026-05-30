import 'package:flutter/material.dart';

import '../../core/haptics/app_haptics.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/context_theme_x.dart';
import '../../l10n/app_localizations.dart';
import '../catalog/view/catalog_page.dart';
import '../inventory/view/inventory_page.dart';
import '../settings/view/settings_page.dart';
import '../urgent/view/urgent_page.dart';

/// Корневой каркас: 4 вкладки (Запасы / Срочное / Справочник / Настройки)
/// и плавающая кнопка «+» для быстрого добавления.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    InventoryPage(),
    UrgentPage(),
    CatalogPage(),
    SettingsPage(),
  ];

  void _select(int i) {
    if (i == _index) return;
    AppHaptics.light();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final showFab = _index != 3;

    return PopScope(
      // С любой вкладки «назад» сначала возвращает на «Запасы»; выходим из
      // приложения только с первой вкладки.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        AppHaptics.light();
        setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: AppHaptics.light,
                backgroundColor: context.colors.accent,
                foregroundColor: context.colors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: _FloatingNav(index: _index, onTap: _select),
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    final items = <({IconData icon, String label})>[
      (icon: Icons.kitchen_outlined, label: l.navInventory),
      (icon: Icons.local_fire_department_outlined, label: l.navUrgent),
      (icon: Icons.menu_book_outlined, label: l.navCatalog),
      (icon: Icons.settings_outlined, label: l.navSettings),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          0,
          AppSpacing.l,
          AppSpacing.m,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _NavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  selected: i == index,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.accent : colors.textFaint;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
