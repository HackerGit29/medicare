import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

enum MindCareButtonVariant { primary, secondary, ghost, danger }

enum MindCareButtonSize { sm, md, lg }

/// MindCare styled button — radius full, DM Sans 600
class MindCareButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final MindCareButtonVariant variant;
  final MindCareButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;

  const MindCareButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MindCareButtonVariant.primary,
    this.size = MindCareButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<MindCareButton> createState() => _MindCareButtonState();
}

class _MindCareButtonState extends State<MindCareButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = _resolveColors();
    final (h, fs, hPad) = _resolveSize();

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
          Text(
            widget.label,
            style: GoogleFonts.dmSans(
              fontSize: fs,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ],
    );

    if (widget.fullWidth) {
      content = Center(child: content);
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.fullWidth ? double.infinity : null,
          height: h,
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(9999),
            border: border != null
                ? Border.all(color: border, width: 1.5)
                : null,
            boxShadow: widget.variant == MindCareButtonVariant.primary
                ? [
                    BoxShadow(
                      color: AppTheme.accentTeal.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }

  (Color, Color, Color?) _resolveColors() {
    switch (widget.variant) {
      case MindCareButtonVariant.primary:
        return (AppTheme.interactive, AppTheme.textInverse, null);
      case MindCareButtonVariant.secondary:
        return (AppTheme.bgSecondary, AppTheme.textPrimary, null);
      case MindCareButtonVariant.ghost:
        return (Colors.transparent, AppTheme.accentTeal, AppTheme.accentTeal);
      case MindCareButtonVariant.danger:
        return (AppTheme.accentDot, AppTheme.textInverse, null);
    }
  }

  (double, double, double) _resolveSize() {
    switch (widget.size) {
      case MindCareButtonSize.sm:
        return (36, 12, 16);
      case MindCareButtonSize.md:
        return (44, 14, 24);
      case MindCareButtonSize.lg:
        return (52, 15, 32);
    }
  }
}

/// Glassmorphic hero CTA button (used on Auth / Hero cards)
class MindCareGlassButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const MindCareGlassButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
