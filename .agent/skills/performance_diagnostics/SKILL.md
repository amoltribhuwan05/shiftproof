---
name: performance
description: Strict Performance Diagnostics & Implementations
---

# Performance Diagnostics

## 1. Const Optimization

- **Mandate `const`:** Enforce the usage of the `const` keyword on all widgets and constructors with immutable parameters. Prevent needless tree rebuilding.

## 2. Heavy Lists & Slivers

- **Prohibit ListView:** Never use standard `ListView` for unbounded, dynamic content walls.
- **Mandate Slivers:** Rely on `CustomScrollView` and sliver implementations (`SliverList`, `SliverGrid`) to build items identically only as they enter the viewport.

## 3. Image Caching & Clipping

- **Network Asset Caching:** Always cache network assets via `cached_network_image`.
- **Restrict Clipping:** Avoid aggressive `Clip.antiAlias` wrappers on large lists unless strictly necessary for card rounding.
