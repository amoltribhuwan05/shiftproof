import 'package:flutter/material.dart';

class FacilityItem extends StatelessWidget {
  const FacilityItem({
    required this.title,
    super.key,
    this.icon,
    this.isMore = false,
  });
  final String title;
  final IconData? icon;
  final bool isMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isMore
                ? (isDark
                      ? theme.colorScheme.surface.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.1))
                : theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: isMore
              ? Center(
                  child: Text(
                    '+5',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                )
              : Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyMedium?.color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
