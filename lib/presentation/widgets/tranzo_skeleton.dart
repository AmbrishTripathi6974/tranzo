import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shared shimmer styling for loading placeholders (history, profile, etc.).
abstract final class TranzoSkeleton {
  static ShimmerEffect effectOf(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ShimmerEffect(
      baseColor: scheme.surfaceContainerHighest.withValues(alpha: 0.85),
      highlightColor: scheme.surfaceContainerLow,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  static Widget wrap(
    BuildContext context, {
    required Widget child,
    bool enabled = true,
  }) {
    return Skeletonizer(
      enabled: enabled,
      effect: effectOf(context),
      ignorePointers: true,
      child: child,
    );
  }
}
