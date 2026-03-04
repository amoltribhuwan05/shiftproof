---
name: signals-and-flutter-hooks
description: Strict Reactive State Management
---

# Reactive State Management

## 1. Stateless First

- **Enforce `StatelessWidget`:** Default to `StatelessWidget`. UI elements must redraw reactively based on external state signals.
- **Prohibit Local Mutation Chains:** Internal `setState` mutation chains are prohibited unless isolated to a single ephemeral animation.

## 2. Implicit Animations

- **Mandate Implicit Over Manual:** Wrap elements in `AnimatedContainer`, `AnimatedOpacity`, or `AnimatedScale` for layout property changes (size, color, padding) instead of manual `AnimationController` setups where possible.

## 3. Ripple and Interaction Feedback

- **Mandate Interactions:** Ensure every interactive UI surface visually responds to touch using `InkWell` or proper Material wrapping.
