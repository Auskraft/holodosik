import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formatting/report_builder.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/expiry.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/bloc/inventory_cubit.dart';

/// «Отчёты»: плашки списков (использованные, просроченные, все, по местам)
/// с копированием в буфер, шарингом текстом и выгрузкой в .txt.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final cubit = context.read<InventoryCubit>();
    final active = cubit.state.all;

    return Scaffold(
      appBar: AppBar(title: Text(l.reportsTitle)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<List<Object>>(
          future: Future.wait([cubit.loadUsedUp(), cubit.loadCustomLocations()]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final usedUp = snapshot.data![0] as List<StockEntry>;
            final custom = snapshot.data![1] as List<String>;
            final today = DateTime.now();
            final expired = active
                .where((e) => e.expiryInfo(today).status == ExpiryStatus.expired)
                .toList();

            // Места: встроенные + пользовательские + встречающиеся в запасах.
            final locations = <String>[];
            for (final loc in [...StorageLocations.builtins, ...custom]) {
              if (!locations.contains(loc)) locations.add(loc);
            }
            for (final e in active) {
              if (!locations.contains(e.location)) locations.add(e.location);
            }

            final tiles = <({String title, int count, String content})>[
              (
                title: l.usedUpTitle,
                count: usedUp.length,
                content: ReportBuilder.buildUsed(usedUp),
              ),
              (
                title: l.reportExpired,
                count: expired.length,
                content: ReportBuilder.build(expired),
              ),
              (
                title: l.reportCurrentAll,
                count: active.length,
                content: ReportBuilder.build(active),
              ),
              for (final loc in locations)
                () {
                  final items = active.where((e) => e.location == loc).toList();
                  return (
                    title: loc,
                    count: items.length,
                    content: ReportBuilder.build(items),
                  );
                }(),
            ];

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                for (final t in tiles) ...[
                  _ReportTile(
                    title: t.title,
                    count: t.count,
                    content: t.content,
                  ),
                  const SizedBox(height: AppSpacing.s),
                ],
                const SizedBox(height: AppSpacing.l),
                Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset('assets/images/pineapple.png', width: 160),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.title,
    required this.count,
    required this.content,
  });

  final String title;
  final int count;
  final String content;

  Future<void> _copy(BuildContext context) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    AppHaptics.light();
    await Clipboard.setData(ClipboardData(text: content));
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(content.isEmpty ? l.reportEmpty : l.reportCopied),
      ));
  }

  /// Сохраняет .txt в доступную папку приложения и возвращает путь.
  Future<File> _saveFile() async {
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/holodos_list.txt');
    await file.writeAsString(content);
    return file;
  }

  Future<void> _download(BuildContext context) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    AppHaptics.light();
    final file = await _saveFile();
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(l.reportSaved),
        action: SnackBarAction(
          label: l.actionOpen,
          onPressed: () => OpenFilex.open(file.path),
        ),
      ));
  }

  Future<void> _openFile(BuildContext context) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    AppHaptics.light();
    final file = await _saveFile();
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l.reportOpenError)));
    }
  }

  Future<void> _shareFile() async {
    AppHaptics.light();
    final file = await _saveFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain', name: '$title.txt')],
        subject: title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.s,
        AppSpacing.xs,
        AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontSize: (context.textTheme.titleMedium?.fontSize ?? 16) - 4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(minWidth: 22),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: count > 0 ? colors.accentSoft : colors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$count',
              style: context.textTheme.labelSmall?.copyWith(
                color: count > 0 ? colors.accentSoftText : colors.textFaint,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          _CompactIcon(
            tooltip: l.reportCopy,
            icon: Icons.content_copy,
            color: colors.textMuted,
            onTap: () => _copy(context),
          ),
          _CompactIcon(
            tooltip: l.reportDownload,
            icon: Icons.download,
            color: colors.accent,
            onTap: () => _download(context),
          ),
          PopupMenuButton<String>(
            tooltip: '',
            color: colors.surface,
            padding: EdgeInsets.zero,
            onSelected: (v) {
              if (v == 'open') _openFile(context);
              if (v == 'share') _shareFile();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'open', child: Text(l.reportOpenFile)),
              PopupMenuItem(value: 'share', child: Text(l.reportShareFile)),
            ],
            child: SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.more_vert, color: colors.textMuted, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactIcon extends StatelessWidget {
  const _CompactIcon({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: 22),
      onPressed: onTap,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
