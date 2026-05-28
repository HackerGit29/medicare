import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import '../application/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'patient';
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _roles = [
    ('patient', 'Patient', HugeIcons.strokeRoundedHospital02),
    ('doctor', 'Médecin', HugeIcons.strokeRoundedStethoscope),
    ('nurse', 'Infirmier', HugeIcons.strokeRoundedInjection),
    ('lab', 'Laborantin', HugeIcons.strokeRoundedMicroscope),
    ('pharm', 'Pharmacien', HugeIcons.strokeRoundedPillsTablet),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    // Prepend role prefix so auth_provider picks the right role
    final emailWithRole = '${_selectedRole}@mindcare.com';
    await ref
        .read(authProvider.notifier)
        .login(emailWithRole, _passwordCtrl.text);
    if (mounted) {
      final err = ref.read(authProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $err'),
            backgroundColor: AppTheme.accentDot,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: Stack(
        children: [
          // ── Gradient hero background ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF2B8CC),
                    Color(0xFFEEC8D8),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radius2xl),
                  bottomRight: Radius.circular(AppTheme.radius2xl),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MindCare',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 32,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Health · Brain · Wellness',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.06,
                        ),
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                          children: [
                            const TextSpan(text: 'Bienvenue\nde retour '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedWavingHand01,
                                color: AppTheme.textPrimary,
                                size: 26.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Form card ──
          Positioned.fill(
            top: size.height * 0.32,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: MindCareCardLarge(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connexion',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sélectionnez votre rôle et connectez-vous',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Role selector chips ──
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _roles.map((r) {
                              final isSelected = _selectedRole == r.$1;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedRole = r.$1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.interactive
                                        : AppTheme.bgSecondary,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      HugeIcon(
                                        icon: r.$3,
                                        color: isSelected
                                            ? AppTheme.textInverse
                                            : AppTheme.textSecondary,
                                        size: 16.0,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        r.$2,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppTheme.textInverse
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // ── Email / Matricule field ──
                          _RoundedField(
                            controller: _emailCtrl,
                            label: 'Email / Matricule',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Champ requis'
                                : null,
                          ),
                          const SizedBox(height: 12),

                          // ── Password field ──
                          _RoundedField(
                            controller: _passwordCtrl,
                            label: 'Mot de passe',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppTheme.textMuted,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) => (v == null || v.length < 4)
                                ? 'Min. 4 caractères'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Mot de passe oublié?',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.textAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── CTA Button ──
                          MindCareButton(
                            label: 'Se connecter',
                            isLoading: authState.isLoading,
                            fullWidth: true,
                            size: MindCareButtonSize.lg,
                            onPressed: _login,
                          ),
                          const SizedBox(height: 16),

                          // ── Biometric hint (patient only) ──
                          if (_selectedRole == 'patient')
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgSecondary,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.fingerprint_rounded,
                                        color: AppTheme.accentTeal,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Connexion biométrique',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _RoundedField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppTheme.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppTheme.accentTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppTheme.accentDot, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9999),
          borderSide: const BorderSide(color: AppTheme.accentDot, width: 1.5),
        ),
      ),
    );
  }
}
