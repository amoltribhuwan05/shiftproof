---
name: material-design
description: Strict Material Design 3 guidelines
---

# Material Design 3 Mastery

## 1. Color System

- **Strict Theme Mapping:** Map all UI colors to `Theme.of(context).colorScheme`.
- **No Hardcoding:** Hardcoded colors are strictly prohibited. Use `primary`, `surface`, `onSurface`, etc.

## 2. Typography

- **Strict Scales:** Enforce defined Material Design 3 type scales (`bodyLarge`, `titleMedium`, `labelSmall`).
- **Tracking/Line-Height:** Ensure proper line-height and letter-spacing tracking match MD3 specs.

## 3. Adaptive Motion

- **Implicit Transitions:** Mandate implicit micro-animations (`AnimatedContainer`, `AnimatedScale`) for UI element state changes.
- **Routing:** Apply standard Material page transitions across all routes.

## 4. Elevation & Shadow

- **Tonal Elevation:** Leverage Material 3's tonal elevation system (`surfaceContainer` values) over hardcoded offset box shadows.
