import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Paramètres',
          style: GoogleFonts.dmSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Profile summary card ──
            MindCareCardLarge(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentBlue, AppTheme.accentMint],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0] : 'U',
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Utilisateur',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MindCareBadge(
                          label: (user?.role ?? 'Role').toUpperCase(),
                          color: AppTheme.bgSecondary,
                          textColor: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Options list ──
            MindCareCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Mode sombre',
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppTheme.accentTeal,
                      onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.bgSecondary),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: 'Langue',
                    subtitle: 'Français (FR)',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppTheme.bgSecondary),
                  _SettingsTile(
                    icon: Icons.security_rounded,
                    title: 'Sécurité et biométrie',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppTheme.bgSecondary),
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Logout CTA ──
            MindCareButton(
              label: 'Se déconnecter',
              variant: MindCareButtonVariant.danger,
              fullWidth: true,
              size: MindCareButtonSize.lg,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 40),
            Text(
              'MindCare v1.0.0',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
