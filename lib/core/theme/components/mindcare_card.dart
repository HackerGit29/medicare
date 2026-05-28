import 'package:flutter/material.dart';
import '../app_theme.dart';

class MindCareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? color;
  final bool useShadow;
  final VoidCallback? onTap;

  const MindCareCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.color,
    this.useShadow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMd),
        boxShadow: useShadow
            ? [
                BoxShadow(
                  color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Large card variant with radius 20px used for main content sections
class MindCareCardLarge extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;

  const MindCareCardLarge({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MindCareCard(
      radius: AppTheme.radiusLg,
      padding: padding ?? const EdgeInsets.all(20),
      color: color,
      onTap: onTap,
      child: child,
    );
  }
}
