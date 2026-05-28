import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
class _PassageNurse {
  final String id;
  final String patientNom;
  final String motif;
  final bool constantesSaisies;

  const _PassageNurse({
    required this.id,
    required this.patientNom,
    required this.motif,
    this.constantesSaisies = false,
  });
}

final _mockPassages = [
  _PassageNurse(
    id: 'P-001',
    patientNom: 'Amadou Diallo',
    motif: 'Douleurs thoraciques',
  ),
  _PassageNurse(
    id: 'P-002',
    patientNom: 'Fatoumata Bah',
    motif: 'Fièvre persistante',
    constantesSaisies: true,
  ),
  _PassageNurse(
    id: 'P-003',
    patientNom: 'Ibrahim Camara',
    motif: 'Suivi post-opératoire',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class NurseScreen extends ConsumerStatefulWidget {
  const NurseScreen({super.key});

  @override
  ConsumerState<NurseScreen> createState() => _NurseScreenState();
}

class _NurseScreenState extends ConsumerState<NurseScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MindCareHeader(
                      userName: user?.name ?? 'Infirmier',
                      onBellTap: () {},
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saisie des constantes vitales',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Summary stats row
                    Row(
                      children: [
                        _SummaryChip(
                          icon: Icons.pending_actions_rounded,
                          label: 'En attente',
                          value: '${_mockPassages.where((p) => !p.constantesSaisies).length}',
                          color: AppTheme.accentCoral,
                        ),
                        const SizedBox(width: 10),
                        _SummaryChip(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Complétés',
                          value: '${_mockPassages.where((p) => p.constantesSaisies).length}',
                          color: AppTheme.accentMint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Passages ouverts',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList.separated(
                itemCount: _mockPassages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final p = _mockPassages[i];
                  final isExpanded = _expandedIndex == i;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: AppTheme.bgPrimary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ── Passage header ──
                        InkWell(
                          onTap: () => setState(() =>
                              _expandedIndex = isExpanded ? null : i),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: p.constantesSaisies
                                        ? AppTheme.accentMint
                                        : AppTheme.accentCoral.withValues(alpha: 0.4),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusMd),
                                  ),
                                  child: Icon(
                                    p.constantesSaisies
                                        ? Icons.check_rounded
                                        : Icons.monitor_heart_outlined,
                                    color: AppTheme.textPrimary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.patientNom,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.motif,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MindCareBadge.status(
                                  p.constantesSaisies ? 'Complété' : 'Attente',
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Expanded form ──
                        if (isExpanded)
                          _ConstantesForm(passageId: p.id),
                      ],
                    ),
                  );
                },
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

// ── Constantes form ───────────────────────────────────────────────────────────
class _ConstantesForm extends StatefulWidget {
  final String passageId;

  const _ConstantesForm({required this.passageId});

  @override
  State<_ConstantesForm> createState() => _ConstantesFormState();
}

class _ConstantesFormState extends State<_ConstantesForm> {
  final _tempCtrl = TextEditingController();
  final _tensionCtrl = TextEditingController();
  final _poulsCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _tailleCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _tempCtrl.dispose();
    _tensionCtrl.dispose();
    _poulsCtrl.dispose();
    _poidsCtrl.dispose();
    _tailleCtrl.dispose();
    _spo2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Constantes enregistrées'),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: AppTheme.bgSecondary),
          const SizedBox(height: 16),
          Text(
            'Constantes vitales',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // ── 2-column grid of vital sign inputs ──
          Row(
            children: [
              _VitalCard(
                emoji: '🌡️',
                label: 'Température (°C)',
                controller: _tempCtrl,
                hint: '37.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(width: 10),
              _VitalCard(
                emoji: '💉',
                label: 'Tension (mmHg)',
                controller: _tensionCtrl,
                hint: '120/80',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _VitalCard(
                emoji: '❤️',
                label: 'Pouls (bpm)',
                controller: _poulsCtrl,
                hint: '72',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(width: 10),
              _VitalCard(
                emoji: '🩸',
                label: 'SpO2 (%)',
                controller: _spo2Ctrl,
                hint: '98',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _VitalCard(
                emoji: '⚖️',
                label: 'Poids (kg)',
                controller: _poidsCtrl,
                hint: '70',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(width: 10),
              _VitalCard(
                emoji: '📏',
                label: 'Taille (cm)',
                controller: _tailleCtrl,
                hint: '175',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 16),

          MindCareButton(
            label: 'Enregistrer les constantes',
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String emoji;
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _VitalCard({
    required this.emoji,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgSecondary,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 0,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.borderSubtle.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.borderSubtle.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.accentTeal,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textPrimary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
