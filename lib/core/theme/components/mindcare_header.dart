import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../app_theme.dart';

/// MindCare Header — "Good Morning, Name 👋" + notification bell
class MindCareHeader extends StatelessWidget {
  final String userName;
  final bool hasNotification;
  final VoidCallback? onBellTap;

  const MindCareHeader({
    super.key,
    required this.userName,
    this.hasNotification = true,
    this.onBellTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              children: [
                TextSpan(text: '${_greeting()},\n'),
                TextSpan(text: '$userName '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedWavingHand01,
                      color: AppTheme.textPrimary,
                      size: 22.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onBellTap,
          child: _BellButton(hasNotification: hasNotification),
        ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  final bool hasNotification;

  const _BellButton({required this.hasNotification});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
          if (hasNotification)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.accentDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bgPrimary, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
