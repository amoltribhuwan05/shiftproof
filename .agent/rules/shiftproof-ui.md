---
trigger: always_on
glob: "lib/**/*.dart"
description: Strict ShiftProof UI Development Rules
---

# ShiftProof UI Rules

## 1. Theming & Styling

- **No Hardcoded Values:** Never use hardcoded colors, text styles, or spacing. Always use `Theme.of(context)`.
- **Centralized Colors:** Enforce mapping to `lib/core/theme/app_theme.dart`.
- **Sky Blue Branding:** Enforce Sky Blue primary variant for active states.
- **Dark Mode Support:** Support dynamic theme switching using `theme.colorScheme` properties.

## 2. Responsiveness & Adaptive Layouts

- **Screen Agnostic:** Ensure layouts do not break across differing aspect ratios. Use `Expanded`, `Flexible`, `SliverGridDelegateWithMaxCrossAxisExtent`, and `LayoutBuilder`.
- **Scrollable Safety:** Prevent strict height overflows by wrapping content in `SingleChildScrollView`, `ListView`, or `CustomScrollView`.
- **SafeArea:** Wrap root layouts in `SafeArea` to avoid notch/navigation bar overlaps.

## 3. Reusability & Widget Architecture

- **Atomic Components:** Isolate modular components in `lib/widgets/`.
- **Stateless Bias:** Default to `StatelessWidget`. Restrict `StatefulWidget` to strict local, ephemeral states (e.g., animations).
- **Parameterization:** Extract distinct prop arguments rather than duplicating similar widget trees.

## 4. State Indication & Feedback

- **Shimmer Loaders:** Use skeleton loading patterns for async data lists. Do not use blocking progress indicators for sub-components.
- **Empty States:** Render explicit state widgets when lists or data payloads are empty.
- **Error States:** Map HTTP or logical errors to actionable fallback UI layouts or Snackbars. Never fail silently.
- **Interactive Feedback:** Wrap interactive elements in `InkWell` (Material bounds).

## 5. Animations & Transitions

- **Implicit Transitions:** Prefer `AnimatedContainer`, `AnimatedScale`, `AnimatedOpacity`.
- **Navigation:** Enforce standardized PageRoutes or Hero transitions between contextual grids and details.

## 6. Layout Precision & Typography

- **8-Point Grid:** Margins and padding must conform to multiples of 8.
- **Material 3 Typography:** Strict adherence to app theme TextStyles.
- **RenderFlex Protection:** Guard constrained text via `TextOverflow.ellipsis`.

## 7. Performance Constraints

- **const Enforcements:** Prepend `const` for unmutating rendering paths.
- **Viewport Yielding:** For heavy dynamic lists, strictly implement `CustomScrollView` with appropriate `Sliver` delegates.
- **Image Network Caching:** Mandate the use of `cached_network_image`. Limit indiscriminate anti-alias clipping.
