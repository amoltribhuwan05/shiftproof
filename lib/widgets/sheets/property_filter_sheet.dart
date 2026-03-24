import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shiftproof/providers/find_pg_provider.dart';

/// Modal bottom sheet for filtering property listings.
/// Returns the updated [PropertyFilters] when the user taps "Apply".
class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet({required this.initial, super.key});

  final PropertyFilters initial;

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late String? _type;
  late String? _sortBy;
  late TextEditingController _locationCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  static const _types = ['PG', 'Flat', 'Shared Room', 'Private Room'];
  static const _sortOptions = [
    ('Newest First', null),
    ('Price: Low to High', 'price_asc'),
    ('Price: High to Low', 'price_desc'),
    ('Highest Rated', 'rating'),
  ];

  @override
  void initState() {
    super.initState();
    _type = widget.initial.type;
    _sortBy = widget.initial.sortBy;
    _locationCtrl = TextEditingController(
      text: widget.initial.location ?? '',
    );
    _minCtrl = TextEditingController(
      text: widget.initial.minPrice?.toString() ?? '',
    );
    _maxCtrl = TextEditingController(
      text: widget.initial.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.pop(
      context,
      PropertyFilters(
        type: _type,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        sortBy: _sortBy,
        minPrice: _minCtrl.text.isEmpty ? null : int.tryParse(_minCtrl.text),
        maxPrice: _maxCtrl.text.isEmpty ? null : int.tryParse(_maxCtrl.text),
      ),
    );
  }

  void _clear() {
    setState(() {
      _type = null;
      _sortBy = null;
      _locationCtrl.clear();
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clear,
                    child: Text(
                      'Clear all',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Property Type ──────────────────────────────────────
                    _sectionLabel(context, 'Property Type'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _types.map((t) {
                        final selected = _type == t;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _type = selected ? null : t),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colorScheme.primary
                                  : (isDark
                                      ? colorScheme.surface
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: selected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── Location ───────────────────────────────────────────
                    _sectionLabel(context, 'Location'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _locationCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. Koramangala, Bangalore',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surface
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Price Range ────────────────────────────────────────
                    _sectionLabel(context, 'Price Range (₹/month)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PriceField(
                            controller: _minCtrl,
                            hint: 'Min',
                            isDark: isDark,
                            theme: theme,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '–',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _PriceField(
                            controller: _maxCtrl,
                            hint: 'Max',
                            isDark: isDark,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Sort By ────────────────────────────────────────────
                    _sectionLabel(context, 'Sort By'),
                    const SizedBox(height: 4),
                    ..._sortOptions.map(((String label, String? value) opt) {
                      final selected = _sortBy == opt.$2;
                      return InkWell(
                        onTap: () => setState(() => _sortBy = opt.$2),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              // Custom radio circle
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.outlineVariant,
                                    width: selected ? 6 : 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                opt.$1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // ── Apply button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _apply,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.theme,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: hint,
        prefixText: '₹ ',
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.surface
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
