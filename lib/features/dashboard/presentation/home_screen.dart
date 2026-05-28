import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/components/components.dart';
import '../../../features/auth/application/auth_provider.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────
class _PatientResult {
  final String nom;
  final String prenom;
  final String matricule;
  final String groupeSanguin;
  final bool hasActivePassage;

  const _PatientResult({
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.groupeSanguin,
    this.hasActivePassage = false,
  });
}

const _allPatients = [
  _PatientResult(
    nom: 'Diallo',
    prenom: 'Amadou',
    matricule: 'PAT-00123',
    groupeSanguin: 'O+',
    hasActivePassage: true,
  ),
  _PatientResult(
    nom: 'Bah',
    prenom: 'Fatoumata',
    matricule: 'PAT-00456',
    groupeSanguin: 'A+',
  ),
  _PatientResult(
    nom: 'Camara',
    prenom: 'Mamadou',
    matricule: 'PAT-00789',
    groupeSanguin: 'B-',
  ),
  _PatientResult(
    nom: 'Sow',
    prenom: 'Aissatou',
    matricule: 'PAT-01011',
    groupeSanguin: 'AB+',
    hasActivePassage: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  List<_PatientResult> _results = [];
  bool _hasSearched = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }
    setState(() {
      _hasSearched = true;
      _results = _allPatients.where((p) {
        return p.nom.toLowerCase().contains(query) ||
            p.prenom.toLowerCase().contains(query) ||
            p.matricule.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showQrScanner() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrScanSheet(),
    );
  }

  void _showCreatePassage(_PatientResult patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreatePassageSheet(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.bgApp,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MindCareHeader(
                      userName: user?.name ?? 'Accueil',
                      onBellTap: () {},
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Agent d\'admission',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Giant QR Scan button ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _QrScanButton(onTap: _showQrScanner),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Search bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recherche manuelle',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: _search,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nom, prénom ou matricule patient...',
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: AppTheme.textMuted,
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _search('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.bgPrimary,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
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
                          borderSide: const BorderSide(
                            color: AppTheme.accentTeal,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Results list ──
            if (_hasSearched && _results.isEmpty)
              SliverToBoxAdapter(
                child: _EmptySearch(query: _searchCtrl.text),
              )
            else if (_results.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _PatientResultCard(
                    patient: _results[i],
                    onCreatePassage: () => _showCreatePassage(_results[i]),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: _RecentAdmissions(),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _QrScanButton extends StatefulWidget {
  final VoidCallback onTap;

  const _QrScanButton({required this.onTap});

  @override
  State<_QrScanButton> createState() => _QrScanButtonState();
}

class _QrScanButtonState extends State<_QrScanButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accentTeal, Color(0xFF2A4A5A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentTeal.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                right: 30,
                bottom: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scanner QR',
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Scannez la carte numérique\ndu patient pour accéder',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              'Appuyer pour scanner',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientResultCard extends StatelessWidget {
  final _PatientResult patient;
  final VoidCallback onCreatePassage;

  const _PatientResultCard({
    required this.patient,
    required this.onCreatePassage,
  });

  @override
  Widget build(BuildContext context) {
    return MindCareCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                patient.nom[0],
                style: GoogleFonts.dmSans(
                  fontSize: 18,
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
                  '${patient.prenom} ${patient.nom}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      patient.matricule,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MindCareBadge(
                      label: patient.groupeSanguin,
                      color: AppTheme.accentDot.withValues(alpha: 0.12),
                      textColor: AppTheme.accentDot,
                    ),
                    if (patient.hasActivePassage) ...[
                      const SizedBox(width: 6),
                      MindCareBadge.status('En cours'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          MindCareButton(
            label: '+ Passage',
            size: MindCareButtonSize.sm,
            onPressed: onCreatePassage,
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Aucun résultat pour "$query"',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Vérifiez l\'orthographe ou essayez\nle matricule patient',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecentAdmissions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admissions récentes',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._allPatients
              .where((p) => p.hasActivePassage)
              .map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PatientResultCard(
                    patient: p,
                    onCreatePassage: () {},
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _QrScanSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.qr_code_scanner_rounded,
              size: 64, color: AppTheme.accentTeal),
          const SizedBox(height: 16),
          Text(
            'Scanner la carte QR',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Placez la carte numérique du patient\ndevant la caméra',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Simulated viewfinder
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Stack(
              children: [
                _Corner(Alignment.topLeft),
                _Corner(Alignment.topRight),
                _Corner(Alignment.bottomLeft),
                _Corner(Alignment.bottomRight),
                Center(
                  child: Text(
                    'Zone de scan',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MindCareButton(
            label: 'Fermer',
            variant: MindCareButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;

  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;
    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;

    return Positioned(
      left: isLeft ? 12 : null,
      right: isLeft ? null : 12,
      top: isTop ? 12 : null,
      bottom: isTop ? null : 12,
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(
          painter: _CornerPainter(
            isLeft: isLeft,
            isTop: isTop,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isLeft;
  final bool isTop;

  _CornerPainter({required this.isLeft, required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentTeal
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isLeft && isTop) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (!isLeft && isTop) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (isLeft && !isTop) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CreatePassageSheet extends StatefulWidget {
  final _PatientResult patient;

  const _CreatePassageSheet({required this.patient});

  @override
  State<_CreatePassageSheet> createState() => _CreatePassageSheetState();
}

class _CreatePassageSheetState extends State<_CreatePassageSheet> {
  final _motifCtrl = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_motifCtrl.text.trim().isEmpty) return;
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passage créé pour ${widget.patient.prenom} ${widget.patient.nom}',
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgPrimary,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer un passage',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.patient.prenom} ${widget.patient.nom} · ${widget.patient.matricule}',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _motifCtrl,
              maxLines: 3,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Motif de la visite...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 13, color: AppTheme.textMuted,
                ),
                filled: true,
                fillColor: AppTheme.bgSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.accentTeal, width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MindCareButton(
                    label: 'Annuler',
                    variant: MindCareButtonVariant.secondary,
                    fullWidth: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MindCareButton(
                    label: 'Créer',
                    fullWidth: true,
                    isLoading: _isCreating,
                    onPressed: _create,
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
