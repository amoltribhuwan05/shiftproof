import 'package:flutter/material.dart';
import '../../widgets/buttons/primary_button.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  String _selectedFormat = 'pdf';

  @override
  Widget build(BuildContext context) {
    // Owner themes use orange custom color based on design
    final customPrimary = const Color(0xffec5b13);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.transparent : Colors.transparent,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
            ),
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
                    customPrimary.withValues(alpha: isDark ? 0.1 : 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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

                // Date Range Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? customPrimary.withValues(alpha: 0.05)
                            : Colors.white,
                        border: Border.all(
                          color: customPrimary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Oct 1, 2023 - Oct 31, 2023',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.calendar_today,
                              color: customPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Select Property Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Property',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark
                            ? customPrimary.withValues(alpha: 0.05)
                            : Colors.white,
                        border: Border.all(
                          color: customPrimary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'All Properties',
                                isExpanded: true,
                                icon: Icon(
                                  Icons.expand_more,
                                  color: customPrimary,
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                ),
                                dropdownColor: isDark
                                    ? Colors.grey.shade900
                                    : Colors.white,
                                items:
                                    [
                                      'All Properties',
                                      'Grandview Apartments',
                                      'Sunset Heights',
                                      'The Marquee Plaza',
                                      'Riverside Lofts',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                        ],
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
                      child: PrimaryButton(
                        text: 'Export Report',
                        icon: Icons.file_download,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Report will be generated and saved to your device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
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
    final isDark = theme.brightness == Brightness.dark;
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
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
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
