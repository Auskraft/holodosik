import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/icons/category_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/bloc/inventory_cubit.dart';
import '../widgets/quantity_editor.dart';

/// Форма добавления запаса. Открывается с FAB (пусто) или из справочника
/// (с предзаполненным продуктом и категорией).
class AddBatchPage extends StatefulWidget {
  const AddBatchPage({
    super.key,
    this.initialProduct,
    this.initialCategory,
    this.editEntry,
  });

  final Product? initialProduct;
  final ProductCategory? initialCategory;

  /// Если задан — форма работает в режиме редактирования партии.
  final StockEntry? editEntry;

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _nameController = TextEditingController();
  QuantityDraft _draft = const QuantityDraft();
  StorageLocation _location = StorageLocation.fridge;
  bool _hasExpiry = false;
  DateTime? _expiryDate;

  List<ProductCategory> _categories = const [];
  ProductCategory? _category;

  bool get _isEditing => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    if (edit != null) {
      _nameController.text = edit.name;
      _draft = QuantityDraft.fromQuantity(edit.quantity);
      _location = edit.location;
      _category = edit.category;
      _hasExpiry = edit.batch.expiryDate != null;
      _expiryDate = edit.batch.expiryDate;
    } else {
      _nameController.text = widget.initialProduct?.name ?? '';
      _category = widget.initialCategory;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = locator<CatalogRepository>();
    await repo.ensureSeeded();
    final cats = await repo.categories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _category ??= widget.initialProduct == null
          ? null
          : cats.where((c) => c.id == widget.initialProduct!.categoryId).firstOrNull;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _category != null &&
      _draft.isValid;

  void _save() {
    final l = AppL10n.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty || _category == null || !_draft.isValid) return;

    AppHaptics.success();
    final cubit = context.read<InventoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final edit = widget.editEntry;

    if (edit != null) {
      final entry = StockEntry(
        product: Product(id: edit.product.id, name: name, categoryId: _category!.id),
        category: _category!,
        batch: StockBatch(
          id: edit.batch.id,
          productId: edit.product.id,
          location: _location,
          quantity: _draft.build(),
          purchaseDate: edit.batch.purchaseDate,
          expiryDate: _hasExpiry ? _expiryDate : null,
          openedDate: edit.batch.openedDate,
          note: edit.batch.note,
          history: edit.batch.history,
        ),
      );
      cubit.updateBatch(entry);
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l.toastSaved)));
    } else {
      final ts = DateTime.now().microsecondsSinceEpoch;
      final product = Product(
        id: widget.initialProduct?.id ?? 'manual_$ts',
        name: name,
        categoryId: _category!.id,
      );
      final entry = StockEntry(
        product: product,
        category: _category!,
        batch: StockBatch(
          id: 'batch_$ts',
          productId: product.id,
          location: _location,
          quantity: _draft.build(),
          purchaseDate: DateTime.now(),
          expiryDate: _hasExpiry ? _expiryDate : null,
        ),
      );
      cubit.addBatch(entry);
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l.toastAdded)));
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l.editTitle : l.addTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: context.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: l.fieldName,
                hintText: l.fieldNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(l.qtyModeTitle),
            const SizedBox(height: AppSpacing.m),
            QuantityEditor(
              draft: _draft,
              onChanged: (d) => setState(() => _draft = d),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(l.fieldCategory),
            const SizedBox(height: AppSpacing.m),
            _CategoryPicker(
              categories: _categories,
              selected: _category,
              onSelected: (c) => setState(() => _category = c),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(l.fieldLocation),
            const SizedBox(height: AppSpacing.m),
            _LocationPicker(
              value: _location,
              onChanged: (loc) => setState(() => _location = loc),
            ),
            const SizedBox(height: AppSpacing.xl),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.fieldExpiry, style: context.textTheme.titleMedium),
              activeThumbColor: colors.accent,
              value: _hasExpiry,
              onChanged: (v) {
                AppHaptics.selection();
                setState(() {
                  _hasExpiry = v;
                  _expiryDate ??= DateTime.now().add(const Duration(days: 7));
                });
              },
            ),
            if (_hasExpiry)
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _expiryDate == null ? l.pickDate : DateFormatter.full(_expiryDate!),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: FilledButton(
            onPressed: _canSave ? _save : null,
            style: FilledButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: colors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Text(_isEditing ? l.saveEdit : l.saveAdd),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: context.textTheme.titleMedium
            ?.copyWith(color: context.colors.textMuted),
      );
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<ProductCategory> categories;
  final ProductCategory? selected;
  final ValueChanged<ProductCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 84,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final colors = context.colors;
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
        itemBuilder: (_, i) {
          final c = categories[i];
          final isSel = c.id == selected?.id;
          return GestureDetector(
            onTap: () {
              AppHaptics.selection();
              onSelected(c);
            },
            child: Container(
              width: 84,
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: isSel ? colors.accentSoft : colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSel ? colors.accent : colors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CategoryIcons.of(c.iconId),
                    color: isSel ? colors.accentSoftText : colors.textMuted,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    c.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: isSel ? colors.accentSoftText : colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({required this.value, required this.onChanged});

  final StorageLocation value;
  final ValueChanged<StorageLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    final labels = {
      StorageLocation.fridge: l.locFridge,
      StorageLocation.freezer: l.locFreezer,
      StorageLocation.pantry: l.locPantry,
    };

    return Wrap(
      spacing: AppSpacing.s,
      children: [
        for (final loc in StorageLocation.values)
          ChoiceChip(
            label: Text(labels[loc]!),
            selected: loc == value,
            showCheckmark: false,
            backgroundColor: colors.surface,
            selectedColor: colors.accentSoft,
            side: BorderSide(color: colors.border),
            labelStyle: context.textTheme.bodySmall?.copyWith(
              color: loc == value ? colors.accentSoftText : colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) {
              AppHaptics.selection();
              onChanged(loc);
            },
          ),
      ],
    );
  }
}
