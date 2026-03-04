---
name: flutter-skill
description: Strict Universal UI/UX Formatting
---

# Universal Flow

## 1. Screen Agnostic Layouts

- **Mandate Fluid Grids:** Utilize `CustomScrollView`, `SliverGrid`, and `LayoutBuilder` / `MediaQuery` to adapt UI elements smoothly across phone, tablet, and landscape layouts.

## 2. Atomic Widget Design

- **Single Responsibility:** Break large screens into singular-responsibility, stateless UI widgets. Place them in `lib/widgets/`.

## 3. Parameterization

- **Prohibit Duplication:** Do not duplicate layout trees. When duplicating UI components, extract them into parameterized widgets.

## 4. Resilient Bounds

- **Prohibit RenderFlex Overflows:** Use `Expanded` or `Flexible` for dynamic content inside rows and columns. Protect scrolling containers with bounded constraints.
