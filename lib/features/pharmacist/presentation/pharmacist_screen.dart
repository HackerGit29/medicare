import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
class _Ordonnance {
  final String id;
  final String patientNom;
  final String medecinNom;
  final List<String> medicaments;
  final DateTime datePrescription;

  const _Ordonnance({
    required this.id,
    required this.patientNom,
    required this.medecinNom,
    required this.medicaments,
    required this.datePrescription,
  });
}

final _mockOrdonnances = [
  _Ordonnance(
    id: 'ORD-001',
    patientNom: 'Amadou Diallo',
    medecinNom: 'Dr. Kamara',
    medicaments: ['Paracétamol 1000mg - 1cp/8h', 'Ibuprofène 400mg - 1cp/jour'],
    datePrescription: DateTime(2026, 5, 28, 10, 15),
  ),
  _Ordonnance(
    id: 'ORD-002',
    patientNom: 'Aissatou Sow',
    medecinNom: 'Dr. Diallo',
    medicaments: ['Amoxicilline 500mg - 2cp/jour', 'Sirop antitussif - 3c/jour'],
    datePrescription: DateTime(2026, 5, 28, 11, 30),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class PharmacistScreen extends ConsumerStatefulWidget {
  const PharmacistScreen({super.key});

  @override
  ConsumerState<PharmacistScreen> createState() => _PharmacistScreenState();
}

class _PharmacistScreenState extends ConsumerState<PharmacistScreen> {
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
                      userName: user?.name ?? 'Pharmacien',
                      onBellTap: () {},
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pharmacie interne',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ordonnances à délivrer',
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
                itemCount: _mockOrdonnances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final ord = _mockOrdonnances[i];
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
                                    color: AppTheme.accentMint.withValues(alpha: 0.25),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusMd),
                                  ),
                                  child: const Icon(
                                    Icons.medication_liquid_outlined,
                                    color: AppTheme.accentTeal,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ord.patientNom,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Par ${ord.medecinNom} · ${ord.medicaments.length} items',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                        if (isExpanded)
                          _DelivranceDetail(ordonnance: ord),
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

// ── Prescription details ───────────────────────────────────────────────────────
class _DelivranceDetail extends StatefulWidget {
  final _Ordonnance ordonnance;

  const _DelivranceDetail({required this.ordonnance});

  @override
  State<_DelivranceDetail> createState() => _DelivranceDetailState();
}

class _DelivranceDetailState extends State<_DelivranceDetail> {
  bool _isDelivering = false;

  Future<void> _deliver() async {
    setState(() => _isDelivering = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isDelivering = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Médicaments délivrés et stock mis à jour'),
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
            'Prescription',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.ordonnance.medicaments.map((med) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: AppTheme.accentTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          med,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          MindCareButton(
            label: 'Valider la délivrance',
            fullWidth: true,
            isLoading: _isDelivering,
            onPressed: _deliver,
          ),
        ],
      ),
    );
  }
}
