import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/context_theme_x.dart';
import '../../l10n/app_localizations.dart';

/// Поле поиска (pill) с иконкой и очисткой.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      style: context.textTheme.bodyLarge,
      decoration: InputDecoration(
        isDense: true,
        hintText: AppL10n.of(context).searchHint,
        hintStyle: context.textTheme.bodyLarge?.copyWith(color: colors.textFaint),
        prefixIcon: Icon(Icons.search, color: colors.textFaint),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: colors.textFaint),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: colors.accent),
        ),
      ),
      onSubmitted: (_) => setState(() {}),
    );
  }
}
