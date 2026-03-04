import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }
}
