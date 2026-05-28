import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
class _DossierPatient {
  final String nom;
  final String prenom;
  final int age;
  final String groupeSanguin;
  final String motif;
  final String statut;
  final DateTime heure;
  final List<String> antecedents;

  const _DossierPatient({
    required this.nom,
    required this.prenom,
    required this.age,
    required this.groupeSanguin,
    required this.motif,
    required this.statut,
    required this.heure,
    this.antecedents = const [],
  });
}

final _mockDossiers = [
  _DossierPatient(
    nom: 'Diallo',
    prenom: 'Amadou',
    age: 45,
    groupeSanguin: 'O+',
    motif: 'Douleurs thoraciques',
    statut: 'En cours',
    heure: DateTime(2026, 5, 28, 9, 15),
    antecedents: ['HTA', 'Diabète T2'],
  ),
  _DossierPatient(
    nom: 'Bah',
    prenom: 'Fatoumata',
    age: 32,
    groupeSanguin: 'A+',
    motif: 'Fièvre persistante',
    statut: 'En cours',
    heure: DateTime(2026, 5, 28, 10, 30),
    antecedents: ['Asthme'],
  ),
  _DossierPatient(
    nom: 'Camara',
    prenom: 'Ibrahim',
    age: 58,
    groupeSanguin: 'B-',
    motif: 'Suivi post-opératoire',
    statut: 'Attente',
    heure: DateTime(2026, 5, 28, 11, 0),
    antecedents: ['Chirurgie cardiaque 2024'],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class DoctorScreen extends ConsumerStatefulWidget {
  const DoctorScreen({super.key});

  @override
  ConsumerState<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends ConsumerState<DoctorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedPatient = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MindCareHeader(
                    userName: user?.name ?? 'Médecin',
                    onBellTap: () {},
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mind Performance Tracker',
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Tab bar (Activity / Rankings style from mockup) ──
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.bgSecondary,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(
                        color: AppTheme.bgPrimary,
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowCardColor.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      labelColor: AppTheme.textPrimary,
                      unselectedLabelColor: AppTheme.textMuted,
                      tabs: const [
                        Tab(text: 'Passages en cours'),
                        Tab(text: 'Consultation'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Tab content ──
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  // ── Tab 1: Liste des passages ──
                  _PassageListTab(
                    dossiers: _mockDossiers,
                    selectedIndex: _selectedPatient,
                    onSelect: (i) {
                      setState(() => _selectedPatient = i);
                      _tabCtrl.animateTo(1);
                    },
                  ),

                  // ── Tab 2: Dossier patient ──
                  _ConsultationTab(dossier: _mockDossiers[_selectedPatient]),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppTheme.bgPrimary,
        child: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
      ),
    );
  }
}

// ── Tab 1: Passage list ───────────────────────────────────────────────────────
class _PassageListTab extends StatelessWidget {
  final List<_DossierPatient> dossiers;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _PassageListTab({
    required this.dossiers,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: dossiers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final d = dossiers[i];
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentTeal.withValues(alpha: 0.08)
                  : AppTheme.bgPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isSelected ? AppTheme.accentTeal : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank number circle (like mockup)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accentTeal
                        : AppTheme.bgSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppTheme.textInverse
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      d.prenom[0],
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${d.prenom} ${d.nom}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        d.motif,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MindCareBadge.status(d.statut),
                    const SizedBox(height: 4),
                    Text(
                      '${d.heure.hour}:${d.heure.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tab 2: Consultation ───────────────────────────────────────────────────────
class _ConsultationTab extends StatefulWidget {
  final _DossierPatient dossier;

  const _ConsultationTab({required this.dossier});

  @override
  State<_ConsultationTab> createState() => _ConsultationTabState();
}

class _ConsultationTabState extends State<_ConsultationTab> {
  final _diagCtrl = TextEditingController();
  final _ordoCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _diagCtrl.dispose();
    _ordoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cloture() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passage de ${widget.dossier.prenom} ${widget.dossier.nom} clôturé',
          ),
          backgroundColor: AppTheme.accentTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dossier;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Patient card (like Rankings "Your result" card in mockup) ──
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentBlue, Color(0xFFB8D8E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      d.prenom[0],
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
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
                        '${d.prenom} ${d.nom}',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          MindCareBadge(
                            label: '${d.age} ans',
                            color: Colors.white.withValues(alpha: 0.4),
                            textColor: AppTheme.textPrimary,
                          ),
                          const SizedBox(width: 8),
                          MindCareBadge(
                            label: d.groupeSanguin,
                            color: AppTheme.accentDot.withValues(alpha: 0.2),
                            textColor: AppTheme.accentDot,
                            icon: Icons.water_drop_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                MindCareBadge.status(d.statut),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Antécédents pills row ──
          if (d.antecedents.isNotEmpty) ...[
            Text(
              'Antécédents médicaux',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: d.antecedents
                  .map(
                    (a) => MindCareBadge(
                      label: a,
                      color: AppTheme.accentCoral.withValues(alpha: 0.5),
                      textColor: AppTheme.textPrimary,
                      icon: Icons.warning_amber_rounded,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // ── Stats row (like mockup: Breath, Notes, Detox) ──
          Row(
            children: [
              _StatTile(
                icon: HugeIcons.strokeRoundedHeartCheck,
                label: 'Motif',
                value: d.motif,
              ),
              const SizedBox(width: 8),
              _StatTile(
                icon: HugeIcons.strokeRoundedClock01,
                value:
                    '${d.heure.hour}h${d.heure.minute.toString().padLeft(2, '0')}',
                label: 'Arrivée',
              ),
              const SizedBox(width: 8),
              _StatTile(
                icon: HugeIcons.strokeRoundedDna,
                label: 'Groupe',
                value: d.groupeSanguin,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Diagnostic form ──
          Text(
            'Diagnostic',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _DoctorTextArea(
            controller: _diagCtrl,
            hint: 'Saisir le diagnostic...',
            icon: Icons.medical_information_outlined,
          ),
          const SizedBox(height: 16),

          // ── Ordonnance form ──
          Text(
            'Ordonnance',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _DoctorTextArea(
            controller: _ordoCtrl,
            hint: 'Médicaments, posologie...',
            icon: Icons.medication_outlined,
          ),
          const SizedBox(height: 24),

          // ── Clôture button ──
          MindCareButton(
            label: 'Clôturer le passage',
            fullWidth: true,
            size: MindCareButtonSize.lg,
            isLoading: _isSaving,
            onPressed: _cloture,
          ),
          const SizedBox(height: 10),
          MindCareButton(
            label: 'Sauvegarder',
            fullWidth: true,
            variant: MindCareButtonVariant.secondary,
            size: MindCareButtonSize.md,
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Données sauvegardées'),
                  backgroundColor: AppTheme.accentTeal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowCardColor.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, color: AppTheme.textPrimary, size: 20.0),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _DoctorTextArea({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(top: 12, left: 4),
          child: Icon(icon, color: AppTheme.textMuted, size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: AppTheme.bgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppTheme.borderSubtle.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.accentTeal, width: 1.5),
        ),
      ),
    );
  }
}
