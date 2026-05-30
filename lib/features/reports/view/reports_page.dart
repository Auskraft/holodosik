import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/formatting/report_builder.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/expiry.dart';
import '../../../domain/entities/stock.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/bloc/inventory_cubit.dart';

/// «Отчёты»: плашки списков (использованные, просроченные, все, по местам)
/// с копированием в буфер и выгрузкой в .txt.
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
        child: FutureBuilder<List<StockEntry>>(
          future: cubit.loadUsedUp(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final usedUp = snapshot.data!;
            final today = DateTime.now();
            final expired = active
                .where((e) => e.expiryInfo(today).status == ExpiryStatus.expired)
                .toList();

            final locations = <String>[];
            for (final e in active) {
              if (!locations.contains(e.location)) locations.add(e.location);
            }

            final tiles = <({String title, List<StockEntry> entries})>[
              (title: l.usedUpTitle, entries: usedUp),
              (title: l.reportExpired, entries: expired),
              (title: l.reportCurrentAll, entries: active),
              for (final loc in locations)
                (title: loc, entries: active.where((e) => e.location == loc).toList()),
            ];

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.l),
              itemCount: tiles.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (_, i) =>
                  _ReportTile(title: tiles[i].title, entries: tiles[i].entries),
            );
          },
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.title, required this.entries});

  final String title;
  final List<StockEntry> entries;

  Future<void> _copy(BuildContext context) async {
    final l = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    AppHaptics.light();
    await Clipboard.setData(ClipboardData(text: ReportBuilder.build(entries)));
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(entries.isEmpty ? l.reportEmpty : l.reportCopied),
      ));
  }

  Future<void> _download(BuildContext context) async {
    AppHaptics.light();
    final text = ReportBuilder.build(entries);
    final dir = await getTemporaryDirectory();
    final safe = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${dir.path}/$safe.txt');
    await file.writeAsString(text);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.s,
        AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${entries.length}',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppL10n.of(context).reportCopy,
            icon: Icon(Icons.content_copy_outlined, color: colors.textMuted),
            onPressed: () => _copy(context),
          ),
          IconButton(
            tooltip: AppL10n.of(context).reportDownload,
            icon: Icon(Icons.download_outlined, color: colors.accent),
            onPressed: () => _download(context),
          ),
        ],
      ),
    );
  }
}
