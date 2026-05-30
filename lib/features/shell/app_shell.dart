import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/haptics/app_haptics.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/context_theme_x.dart';
import '../../l10n/app_localizations.dart';
import '../add_batch/view/add_batch_page.dart';
import '../inventory/bloc/inventory_cubit.dart';
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

  // Вкладки строятся при первом открытии и затем сохраняют состояние в стеке.
  static const _builders = <Widget Function()>[
    InventoryPage.new,
    UrgentPage.new,
    SettingsPage.new,
  ];
  final List<Widget?> _pages = List.filled(_builders.length, null);

  @override
  void initState() {
    super.initState();
    _pages[_index] = _builders[_index]();
  }

  void _select(int i) {
    if (i == _index) return;
    AppHaptics.light();
    setState(() {
      _index = i;
      _pages[i] ??= _builders[i]();
    });
  }

  @override
  Widget build(BuildContext context) {
    final showFab = _index != 2;

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
        body: IndexedStack(
          index: _index,
          children: [
            for (final page in _pages) page ?? const SizedBox.shrink(),
          ],
        ),
        floatingActionButton: showFab
            ? FloatingActionButton(
                onPressed: () {
                  AppHaptics.light();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddBatchPage()),
                  );
                },
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
    final attention =
        context.watch<InventoryCubit>().state.attentionCount;

    final items = <({IconData icon, String label, int badge})>[
      (icon: Icons.kitchen_outlined, label: l.navInventory, badge: 0),
      (icon: Icons.local_fire_department_outlined, label: l.navUrgent, badge: attention),
      (icon: Icons.settings_outlined, label: l.navSettings, badge: 0),
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
                  badge: items[i].badge,
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
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

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
            _IconWithBadge(icon: icon, color: color, badge: badge),
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

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.color,
    required this.badge,
  });

  final IconData icon;
  final Color color;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24, color: color),
        if (badge > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: colors.expired,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: colors.surface, width: 1.5),
              ),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
