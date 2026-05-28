import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data models ──────────────────────────────────────────────────────────
class _Passage {
  final String id;
  final String motif;
  final DateTime date;
  final String statut;
  final String medecin;

  const _Passage({
    required this.id,
    required this.motif,
    required this.date,
    required this.statut,
    required this.medecin,
  });
}

final _mockPassages = [
  _Passage(
    id: 'P-001',
    motif: 'Consultation générale',
    date: DateTime(2026, 5, 22),
    statut: 'Cloturé',
    medecin: 'Dr. Kamara',
  ),
  _Passage(
    id: 'P-002',
    motif: 'Bilan sanguin',
    date: DateTime(2026, 5, 15),
    statut: 'Cloturé',
    medecin: 'Dr. Bah',
  ),
  _Passage(
    id: 'P-003',
    motif: 'Suivi tension artérielle',
    date: DateTime(2026, 4, 30),
    statut: 'Cloturé',
    medecin: 'Dr. Kamara',
  ),
  _Passage(
    id: 'P-004',
    motif: 'Urgence - Douleurs thoraciques',
    date: DateTime(2026, 4, 10),
    statut: 'Cloturé',
    medecin: 'Dr. Diallo',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class PatientScreen extends ConsumerStatefulWidget {
  const PatientScreen({super.key});

  @override
  ConsumerState<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends ConsumerState<PatientScreen> {
  bool _isRefreshing = false;
  final List<double> _chartValues = [0.55, 0.4, 0.6, 1.0, 0.75, 0.5, 0.45];
  final List<String> _days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
  int _selectedDay = 3; // Wednesday highlighted
  int _selectedDate = 22;

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final patientName = user?.name ?? 'Patient';

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.accentTeal,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top safe area header ──
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MindCareHeader(userName: patientName, onBellTap: () {}),
                      const SizedBox(height: 20),

                      // ── Date strip ──
                      _DateStrip(
                        selectedDate: _selectedDate,
                        onDateSelected: (d) =>
                            setState(() => _selectedDate = d),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // ── White rounded main content card ──
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.bgPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowCardColor.withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient info header
                    _PatientInfoHeader(name: patientName),
                    const SizedBox(height: 24),

                    // ── Consistency Score section ──
                    Text(
                      'Score de cohérence',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ConsistencyChart(
                      values: _chartValues,
                      days: _days,
                      selectedIndex: _selectedDay,
                      onDaySelected: (i) => setState(() => _selectedDay = i),
                    ),
                    const SizedBox(height: 24),

                    // ── Favorite activities ──
                    Text(
                      'Activités favorites',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        MindCarePill.mindDetox(),
                        const SizedBox(width: 10),
                        MindCarePill.gratitude(),
                        const SizedBox(width: 10),
                        MindCarePill.consciousBreath(),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Historique des passages ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Historique des passages',
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              sliver: SliverList.separated(
                itemCount: _isRefreshing ? 0 : _mockPassages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _PassageCard(passage: _mockPassages[i]),
              ),
            ),

            if (_isRefreshing)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                      color: AppTheme.accentTeal,
                    ),
                  ),
                ),
              ),

            // Bottom padding for nav
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      // Floating settings button
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => context.push('/settings'),
        backgroundColor: AppTheme.bgPrimary,
        child: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _PatientInfoHeader extends StatelessWidget {
  final String name;

  const _PatientInfoHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppTheme.accentPink, AppTheme.accentPurple],
            ),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'P',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textInverse,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  MindCareBadge(
                    label: '32 ans',
                    color: AppTheme.bgSecondary,
                    textColor: AppTheme.textSecondary,
                    icon: Icons.cake_outlined,
                  ),
                  MindCareBadge(
                    label: 'O+',
                    color: AppTheme.accentDot.withValues(alpha: 0.12),
                    textColor: AppTheme.accentDot,
                    icon: Icons.water_drop_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  final int selectedDate;
  final ValueChanged<int> onDateSelected;

  const _DateStrip({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dates = List.generate(7, (i) => now.day - 3 + i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jeudi, ${now.day} Oct',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.bgPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowCardColor.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((d) {
              final isSelected = d == selectedDate;
              return GestureDetector(
                onTap: () => onDateSelected(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.interactive
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$d',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.textInverse
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ConsistencyChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const _ConsistencyChart({
    required this.values,
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avg label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.textPrimary,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            'Avg. 12.3%',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textInverse,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Bars
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final isActive = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isActive)
                        Text(
                          '12.4',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 60 * values[i],
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.interactive
                              : AppTheme.bgSecondary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusSm),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        // Day labels
        Row(
          children: List.generate(days.length, (i) {
            final isActive = i == selectedIndex;
            return Expanded(
              child: Text(
                days[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.textAccent : AppTheme.textMuted,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PassageCard extends StatelessWidget {
  final _Passage passage;

  const _PassageCard({required this.passage});

  @override
  Widget build(BuildContext context) {
    return MindCareCard(
      onTap: () {},
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.bgTertiary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
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
                  passage.motif,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${passage.medecin} · ${passage.date.day}/${passage.date.month}/${passage.date.year}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MindCareBadge.status(passage.statut),
        ],
      ),
    );
  }
}
