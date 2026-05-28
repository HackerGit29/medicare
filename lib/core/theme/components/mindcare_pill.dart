import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

/// Activity category pill — colored background, title + duration + icon
/// Matches the DESIGN.md "7.5 Activity Category Pills" spec exactly
class MindCarePill extends StatelessWidget {
  final String title;
  final String? duration;
  final String emoji;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const MindCarePill({
    super.key,
    required this.title,
    this.duration,
    required this.emoji,
    required this.backgroundColor,
    this.onTap,
  });

  /// Preset: Mind Detox (purple)
  factory MindCarePill.mindDetox({String? duration, VoidCallback? onTap}) =>
      MindCarePill(
        title: 'Mind Detox',
        duration: duration ?? '13h',
        emoji: '🧠',
        backgroundColor: AppTheme.accentPurple,
        onTap: onTap,
      );

  /// Preset: Gratitude Notes (coral)
  factory MindCarePill.gratitude({String? duration, VoidCallback? onTap}) =>
      MindCarePill(
        title: 'Gratitude Notes',
        duration: duration ?? '34h',
        emoji: '✳️',
        backgroundColor: AppTheme.accentCoral,
        onTap: onTap,
      );

  /// Preset: Conscious Breath (sage green)
  factory MindCarePill.consciousBreath({String? duration, VoidCallback? onTap}) =>
      MindCarePill(
        title: 'Conscious Breath',
        duration: duration ?? '34h',
        emoji: '🌿',
        backgroundColor: AppTheme.accentSage,
        onTap: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowCardColor.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                if (duration != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 10,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        duration!,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small badge pill — used for status indicators and tags
class MindCareBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  const MindCareBadge({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
  });

  factory MindCareBadge.status(String status) {
    final (bg, fg) = switch (status.toLowerCase()) {
      'ouvert' || 'open' || 'en cours' => (AppTheme.accentMint, AppTheme.textAccent),
      'cloturé' || 'closed' || 'terminé' => (AppTheme.bgSecondary, AppTheme.textMuted),
      'urgent' => (AppTheme.accentDot.withValues(alpha: 0.15), AppTheme.accentDot),
      'attente' || 'pending' => (AppTheme.accentCoral, AppTheme.textPrimary),
      _ => (AppTheme.bgSecondary, AppTheme.textSecondary),
    };
    return MindCareBadge(label: status, color: bg, textColor: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: textColor ?? AppTheme.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppTheme.textSecondary,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
