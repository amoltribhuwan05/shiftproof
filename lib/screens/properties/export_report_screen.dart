import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';

class ExportReportScreen extends ConsumerStatefulWidget {
  const ExportReportScreen({super.key, this.propertyId = ''});

  final String propertyId;

  @override
  ConsumerState<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends ConsumerState<ExportReportScreen> {
  String _selectedFormat = 'pdf';
  String? _selectedPropertyId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPropertyId = widget.propertyId.isEmpty ? null : widget.propertyId;
  }

  Future<void> _handleExport() async {
    final propertyId = _selectedPropertyId;
    if (propertyId == null || propertyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a property.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Fetch the report data from the backend.
      final report = await ref
          .read(reportServiceProvider)
          .getPropertyReport(propertyId);

      if (mounted) {
        unawaited(showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Report Generated'),
            content: Text(
              'Month: ${report.month.isEmpty ? 'Current' : report.month}\n'
              'Total Collected: ₹${report.totalCollected}\n'
              'Total Pending: ₹${report.totalPending}\n'
              'Payments: ${report.paidCount} paid, ${report.pendingCount} pending',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        ));
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customPrimary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final propertiesAsync = ref.watch(propertiesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          'Export Report',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [NotificationBellButton()],
      ),
      body: Stack(
        children: [
          // Background graphic
          Positioned(
            bottom: -64,
            right: -64,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    customPrimary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Select Format Section
                const Text(
                  'Select Format',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                RadioGroup<String>(
                  groupValue: _selectedFormat,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFormat = newValue;
                      });
                    }
                  },
                  child: Column(
                    children: [
                      _buildFormatOption(
                        context,
                        title: 'PDF Report',
                        subtitle: 'Best for sharing and printing',
                        icon: Icons.picture_as_pdf,
                        value: 'pdf',
                        customPrimary: customPrimary,
                      ),
                      const SizedBox(height: 12),
                      _buildFormatOption(
                        context,
                        title: 'Excel Spreadsheet',
                        subtitle: 'Best for data analysis and accounting',
                        icon: Icons.table_view,
                        value: 'excel',
                        customPrimary: customPrimary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Filters Section
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Select Property
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Property',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? customPrimary.withValues(alpha: 0.05)
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: customPrimary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: propertiesAsync.when(
                        loading: () => const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => const Center(
                          child: Text('Failed to load properties'),
                        ),
                        data: (properties) {
                          // Set default selection to the first property if not set
                          if (_selectedPropertyId == null &&
                              properties.isNotEmpty) {
                            unawaited(
                              Future.microtask(() {
                                if (mounted) {
                                  setState(() {
                                    _selectedPropertyId = properties.first.id;
                                  });
                                }
                              }),
                            );
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPropertyId,
                              hint: const Text('Select a property'),
                              isExpanded: true,
                              icon: Icon(
                                Icons.expand_more,
                                color: customPrimary,
                              ),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                              ),
                              dropdownColor: theme.colorScheme.surface,
                              items: properties.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.id,
                                  child: Text(
                                    p.title ?? 'Unnamed Property',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedPropertyId = value);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120), // Padding for bottom button
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customPrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _handleExport,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.file_download),
                        label: Text(
                          _isLoading ? 'Generating...' : 'Export Report',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Report will be generated from live payment data.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color customPrimary,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedFormat == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFormat = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? customPrimary.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? customPrimary.withValues(alpha: 0.5)
                : customPrimary.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: customPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: customPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: Radio<String>(
                value: value,
                activeColor: customPrimary,
                fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                  if (states.contains(WidgetState.selected)) {
                    return customPrimary;
                  }
                  return customPrimary.withValues(alpha: 0.5);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
