import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
class _ExamenAttente {
  final String id;
  final String patientNom;
  final String type;
  final DateTime prescription;
  final bool enUrgence;

  const _ExamenAttente({
    required this.id,
    required this.patientNom,
    required this.type,
    required this.prescription,
    this.enUrgence = false,
  });
}

final _mockExamens = [
  _ExamenAttente(
    id: 'EX-001',
    patientNom: 'Amadou Diallo',
    type: 'NFS, Plaquettes, CRP',
    prescription: DateTime(2026, 5, 28, 9, 30),
    enUrgence: true,
  ),
  _ExamenAttente(
    id: 'EX-002',
    patientNom: 'Fatoumata Bah',
    type: 'Test de paludisme (TDR)',
    prescription: DateTime(2026, 5, 28, 10, 45),
  ),
  _ExamenAttente(
    id: 'EX-003',
    patientNom: 'Mamadou Camara',
    type: 'Glycémie à jeun',
    prescription: DateTime(2026, 5, 28, 11, 15),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class LabScreen extends ConsumerStatefulWidget {
  const LabScreen({super.key});

  @override
  ConsumerState<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends ConsumerState<LabScreen> {
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
                      userName: user?.name ?? 'Laborantin',
                      onBellTap: () {},
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Examens de laboratoire',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Examens en attente',
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
                itemCount: _mockExamens.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final ex = _mockExamens[i];
                  final isExpanded = _expandedIndex == i;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: AppTheme.bgPrimary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: ex.enUrgence
                          ? Border.all(color: AppTheme.accentDot, width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowCardColor.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => setState(
                            () => _expandedIndex = isExpanded ? null : i,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgTertiary,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.biotech_outlined,
                                    color: AppTheme.accentTeal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex.patientNom,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ex.type,
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
                                if (ex.enUrgence) ...[
                                  MindCareBadge.status('Urgent'),
                                  const SizedBox(width: 8),
                                ],
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
                        if (isExpanded) _ResultatForm(examenId: ex.id),
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

// ── Result form ───────────────────────────────────────────────────────────────
class _ResultatForm extends StatefulWidget {
  final String examenId;

  const _ResultatForm({required this.examenId});

  @override
  State<_ResultatForm> createState() => _ResultatFormState();
}

class _ResultatFormState extends State<_ResultatForm> {
  final _resCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _resCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_resCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Résultats soumis au dossier'),
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
            'Saisie des résultats',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _resCtrl,
            maxLines: 4,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Valeurs mesurées, observations...',
              hintStyle: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
              filled: true,
              fillColor: AppTheme.bgSecondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: const BorderSide(
                  color: AppTheme.accentTeal,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          MindCareButton(
            label: 'Soumettre les résultats',
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
