import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/formatting/date_formatter.dart';
import '../../../core/formatting/quantity_formatter.dart';
import '../../../core/formatting/unit_labels.dart';
import '../../../core/haptics/app_haptics.dart';
import '../../../core/icons/ingredient_emoji.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/context_theme_x.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/quantity.dart';
import '../../../domain/entities/stock.dart';
import '../../../domain/entities/storage.dart';
import '../../../domain/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../inventory/bloc/inventory_cubit.dart';

/// Форма «Новый запас»: поиск продукта в справочнике (с его единицами),
/// добавление своего продукта, место хранения и срок.
class AddBatchPage extends StatefulWidget {
  const AddBatchPage({
    super.key,
    this.editEntry,
    this.initialProduct,
    this.initialCategory,
  });

  /// Если задан — режим редактирования партии.
  final StockEntry? editEntry;

  /// Предвыбранный продукт (например, «Ещё партию» или «+» из справочника).
  final Product? initialProduct;
  final ProductCategory? initialCategory;

  @override
  State<AddBatchPage> createState() => _AddBatchPageState();
}

class _AddBatchPageState extends State<AddBatchPage> {
  final _searchCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  List<Product> _all = const [];
  List<Product> _recent = const [];
  Map<String, ProductCategory> _categoryById = const {};
  bool _loading = true;

  Product? _selected;
  ProductCategory? _selectedCategory;
  List<String> _unitOptions = const ['шт'];
  String _unit = 'шт';
  double _amount = 1;

  String _location = StorageLocations.fridge;
  List<String> _knownLocations = StorageLocations.builtins;
  bool _hasExpiry = false;
  DateTime? _expiryDate;

  bool get _isEditing => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = locator<CatalogRepository>();
    final inventory = context.read<InventoryCubit>();
    await repo.ensureSeeded();
    final products = await repo.products();
    final categories = await repo.categories();
    final usedUp = await inventory.loadUsedUp();
    final customLocations = await inventory.loadCustomLocations();
    if (!mounted) return;

    final byId = {for (final c in categories) c.id: c};

    // Ранее добавленные: уникальные продукты из активных и использованных партий.
    final seen = <String>{};
    final recent = <Product>[];
    final locations = [...StorageLocations.builtins, ...customLocations];
    for (final e in [...inventory.state.all, ...usedUp]) {
      byId.putIfAbsent(e.category.id, () => e.category);
      if (!locations.contains(e.location)) locations.add(e.location);
      if (seen.add(e.product.id)) {
        final matched = products.where((p) => p.id == e.product.id).firstOrNull;
        recent.add(matched ?? e.product);
      }
    }

    final edit = widget.editEntry;
    setState(() {
      _all = products;
      _recent = recent;
      _categoryById = byId;
      _knownLocations = locations;
      _loading = false;
      if (edit != null) {
        _selected = edit.product;
        _selectedCategory = edit.category;
        final matched = products
            .where((p) => p.id == edit.product.id)
            .firstOrNull;
        _unitOptions = _ensureUnit(
          matched?.units ?? const ['шт'],
          edit.quantity.unit,
        );
        _unit = edit.quantity.unit;
        _amount = edit.quantity.amount;
        _amountCtrl.text = QuantityFormatter.number(_amount);
        _location = edit.location;
        _hasExpiry = edit.batch.expiryDate != null;
        _expiryDate = edit.batch.expiryDate;
      } else if (widget.initialProduct != null) {
        final init = widget.initialProduct!;
        final matched = products.where((p) => p.id == init.id).firstOrNull;
        final units = (matched?.units ?? init.units);
        _selected = matched ?? init;
        _selectedCategory = widget.initialCategory ?? byId[init.categoryId];
        _unitOptions = units.isEmpty ? const ['шт'] : units;
        _unit = _unitOptions.first;
        _amount = UnitLabels.defaultAmount(_unit);
        _amountCtrl.text = QuantityFormatter.number(_amount);
      }
    });
  }

  List<String> _ensureUnit(List<String> units, String unit) {
    final list = units.isEmpty ? <String>['шт'] : List<String>.from(units);
    if (!list.contains(unit)) list.insert(0, unit);
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _select(Product product) {
    AppHaptics.selection();
    FocusScope.of(context).unfocus();
    setState(() {
      _selected = product;
      _selectedCategory = _categoryById[product.categoryId];
      _unitOptions = product.units.isEmpty ? const ['шт'] : product.units;
      _unit = _unitOptions.first;
      _amount = UnitLabels.defaultAmount(_unit);
      _amountCtrl.text = QuantityFormatter.number(_amount);
    });
  }

  void _addManually() {
    final name = _searchCtrl.text.trim();
    if (name.isEmpty) return;
    final category = ProductCategory(
      id: 'custom',
      name: AppL10n.of(context).categoryOther,
      iconId: 'other',
    );
    final product = Product(
      id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      categoryId: 'custom',
      units: const ['шт', 'г', 'кг', 'мл', 'л'],
    );
    _categoryById = {..._categoryById, 'custom': category};
    _select(product);
  }

  void _clearSelection() {
    setState(() {
      _selected = null;
      _selectedCategory = null;
    });
  }

  void _setUnit(String unit) {
    setState(() {
      _unit = unit;
      _amount = UnitLabels.defaultAmount(unit);
      _amountCtrl.text = QuantityFormatter.number(_amount);
    });
  }

  bool get _canSave =>
      _selected != null && _selectedCategory != null && _amount > 0;

  void _save() {
    if (!_canSave) return;
    AppHaptics.success();
    final l = AppL10n.of(context);
    final cubit = context.read<InventoryCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final quantity = Quantity(amount: _amount, unit: _unit);
    final edit = widget.editEntry;

    if (edit != null) {
      final entry = StockEntry(
        product: _selected!,
        category: _selectedCategory!,
        batch: StockBatch(
          id: edit.batch.id,
          productId: _selected!.id,
          location: _location,
          quantity: quantity,
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
      final entry = StockEntry(
        product: _selected!,
        category: _selectedCategory!,
        batch: StockBatch(
          id: 'batch_$ts',
          productId: _selected!.id,
          location: _location,
          quantity: quantity,
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

  Future<void> _addLocation() async {
    final l = AppL10n.of(context);
    final cubit = context.read<InventoryCubit>();
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(l.addLocationTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.addLocationHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.add),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      AppHaptics.selection();
      if (!StorageLocations.builtins.contains(name)) {
        await cubit.addLocation(name);
      }
      if (!mounted) return;
      setState(() {
        if (!_knownLocations.contains(name)) {
          _knownLocations = [..._knownLocations, name];
        }
        _location = name;
      });
    }
  }

  Future<void> _editLocation(String location) async {
    // Встроенные места не редактируем и не удаляем.
    if (StorageLocations.builtins.contains(location)) return;
    AppHaptics.light();
    final l = AppL10n.of(context);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.locationRename),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: context.colors.expiredText),
              title: Text(l.locationDelete),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'rename') {
      await _renameLocation(location);
    } else if (action == 'delete') {
      await context.read<InventoryCubit>().deleteLocation(location);
      if (!mounted) return;
      setState(() {
        _knownLocations = _knownLocations.where((e) => e != location).toList();
        if (_location == location) _location = StorageLocations.fridge;
      });
    }
  }

  Future<void> _renameLocation(String from) async {
    final l = AppL10n.of(context);
    final controller = TextEditingController(text: from);
    final to = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(l.locationRename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l.addLocationHint),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l.add),
          ),
        ],
      ),
    );
    if (!mounted || to == null || to.isEmpty || to == from) return;
    await context.read<InventoryCubit>().renameLocation(from, to);
    if (!mounted) return;
    setState(() {
      _knownLocations = [
        for (final e in _knownLocations) if (e == from) to else e,
      ];
      if (_location == from) _location = to;
    });
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
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l.editTitle : l.addTitle)),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (!_isEditing && _selected == null) _searchBar(),
                  Expanded(
                    child: _selected == null ? _resultsList() : _selectedForm(),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _selected == null ? null : _saveBar(),
    );
  }

  Widget _searchBar() {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        style: context.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: AppL10n.of(context).addSearchHint,
          prefixIcon: Icon(Icons.search, color: colors.textFaint),
          suffixIcon: _searchCtrl.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close, color: colors.textFaint),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                  },
                ),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: colors.border),
          ),
        ),
      ),
    );
  }

  List<Product> _search() {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _all.take(30).toList();
    bool matches(Product p) {
      final cat = _categoryById[p.categoryId]?.name.toLowerCase() ?? '';
      return p.name.toLowerCase().contains(q) || cat.contains(q);
    }

    final all = _all.where(matches).toList();
    final starts = all.where((p) => p.name.toLowerCase().startsWith(q));
    final rest = all.where((p) => !p.name.toLowerCase().startsWith(q));
    return [...starts, ...rest].take(50).toList();
  }

  Widget _resultsList() {
    final l = AppL10n.of(context);
    final query = _searchCtrl.text.trim();

    if (query.isEmpty) {
      // Пустой поиск — ранее добавленные продукты + маскоты на фоне снизу.
      final Widget content = _recent.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  l.searchPromptEmpty,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.colors.textFaint),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.giant,
              ),
              children: [
                _categoryHeader(l.recentTitle),
                for (final p in _recent) _resultTile(p),
              ],
            );

      return Stack(
        children: [
          const Positioned.fill(child: _AddMascots()),
          Positioned.fill(child: content),
        ],
      );
    }

    final rows = <Widget>[_manualButton(l, query)];
    String? lastCat;
    for (final p in _search()) {
      final cat = _categoryById[p.categoryId];
      if (cat?.id != lastCat) {
        lastCat = cat?.id;
        rows.add(_categoryHeader(cat?.name ?? ''));
      }
      rows.add(_resultTile(p));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        0,
        AppSpacing.l,
        AppSpacing.giant,
      ),
      children: rows,
    );
  }

  Widget _manualButton(AppL10n l, String name) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: InkWell(
        onTap: _addManually,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: colors.accentSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: colors.accentSoftText, size: 20),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  l.addManually(name),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.accentSoftText,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryHeader(String name) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.l, bottom: AppSpacing.s),
    child: Text(
      name,
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colors.textMuted,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _resultTile(Product p) {
    final colors = context.colors;
    final cat = _categoryById[p.categoryId];
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: () => _select(p),
        leading: Text(
          ProductEmoji.of(p.name, category: cat?.name ?? ''),
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(p.name, style: context.textTheme.bodyLarge),
        trailing: Icon(Icons.add_circle_outline, color: colors.accent),
      ),
    );
  }

  Widget _selectedForm() {
    final l = AppL10n.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        _selectedCard(l),
        const SizedBox(height: AppSpacing.xl),
        _SectionTitle(l.fieldLocation),
        const SizedBox(height: AppSpacing.m),
        _LocationPicker(
          value: _location,
          locations: _knownLocations,
          onChanged: (loc) => setState(() => _location = loc),
          onAddNew: _addLocation,
          onLongPress: _editLocation,
        ),
        const SizedBox(height: AppSpacing.xl),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l.fieldExpiry, style: context.textTheme.titleMedium),
          activeThumbColor: context.colors.accent,
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
              _expiryDate == null
                  ? l.pickDate
                  : DateFormatter.full(_expiryDate!),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colors.text,
              side: BorderSide(color: context.colors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
      ],
    );
  }

  Widget _selectedCard(AppL10n l) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ProductEmoji.of(
                  _selected!.name,
                  category: _selectedCategory?.name ?? '',
                ),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  _selected!.name,
                  style: context.textTheme.titleMedium,
                ),
              ),
              if (!_isEditing)
                TextButton(
                  onPressed: _clearSelection,
                  child: Text(l.actionEdit),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.fieldAmount,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: context.textTheme.titleLarge,
                      onChanged: (v) {
                        final parsed = double.tryParse(v.replaceAll(',', '.'));
                        setState(() => _amount = parsed ?? 0);
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: colors.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: colors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.fieldUnit,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _unit,
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          style: context.textTheme.bodyMedium,
                          items: [
                            for (final u in _unitOptions)
                              DropdownMenuItem(
                                value: u,
                                child: Text(
                                  UnitLabels.label(u),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              AppHaptics.selection();
                              _setUnit(v);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _saveBar() {
    final l = AppL10n.of(context);
    final colors = context.colors;
    return SafeArea(
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
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.titleMedium?.copyWith(
      color: context.colors.textMuted,
    ),
  );
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({
    required this.value,
    required this.locations,
    required this.onChanged,
    required this.onAddNew,
    required this.onLongPress,
  });

  final String value;
  final List<String> locations;
  final ValueChanged<String> onChanged;
  final VoidCallback onAddNew;
  final ValueChanged<String> onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final options = locations.contains(value) ? locations : [...locations, value];

    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        for (final loc in options)
          GestureDetector(
            onLongPress: () => onLongPress(loc),
            child: ChoiceChip(
              label: Text(loc),
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
          ),
        ActionChip(
          avatar: Icon(Icons.add, size: 18, color: colors.accent),
          label: Text(AppL10n.of(context).addLocationChip),
          backgroundColor: colors.surface,
          side: BorderSide(color: colors.accent.withValues(alpha: 0.4)),
          labelStyle: context.textTheme.bodySmall?.copyWith(
            color: colors.accent,
            fontWeight: FontWeight.w600,
          ),
          onPressed: onAddNew,
        ),
      ],
    );
  }
}

/// Маскоты-декор внизу экрана «Новый запас» (при пустом поиске).
class _AddMascots extends StatelessWidget {
  const _AddMascots();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Stack(
            children: [
              Positioned(
                left: -w * 0.04,
                bottom: 0,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset('assets/images/add_tomato.png', width: w * 0.38),
                ),
              ),
              Positioned(
                right: -w * 0.04,
                bottom: 0,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset('assets/images/add_pepper.png', width: w * 0.38),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
