import 'dart:convert';

class PassageMedical {
  final String id; 
  final String idPatient;
  final int idHopital;
  final int idCreateur;
  final DateTime dateAdmission;
  final DateTime? dateCloture;
  final String motifVisite;
  final Map<String, dynamic>? constantesVitales;
  final String? diagnostic;
  final String? prescriptionOrdonnance;
  final String statutPassage; 

  const PassageMedical({
    required this.id,
    required this.idPatient,
    required this.idHopital,
    required this.idCreateur,
    required this.dateAdmission,
    this.dateCloture,
    required this.motifVisite,
    this.constantesVitales,
    this.diagnostic,
    this.prescriptionOrdonnance,
    this.statutPassage = 'en_cours',
  });

  factory PassageMedical.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? constantes;
    if (json['constantes_vitales'] != null) {
      if (json['constantes_vitales'] is String) {
        constantes = jsonDecode(json['constantes_vitales'] as String) as Map<String, dynamic>;
      } else {
        constantes = Map<String, dynamic>.from(json['constantes_vitales'] as Map);
      }
    }

    return PassageMedical(
      id: json['id_passage'] as String,
      idPatient: json['id_patient'] as String,
      idHopital: json['id_hopital'] as int,
      idCreateur: json['id_createur'] as int,
      dateAdmission: DateTime.parse(json['date_admission'] as String),
      dateCloture: json['date_cloture'] != null ? DateTime.parse(json['date_cloture'] as String) : null,
      motifVisite: json['motif_visite'] as String,
      constantesVitales: constantes,
      diagnostic: json['diagnostic'] as String?,
      prescriptionOrdonnance: json['prescription_ordonnance'] as String?,
      statutPassage: json['statut_passage'] as String? ?? 'en_cours',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_passage': id,
      'id_patient': idPatient,
      'id_hopital': idHopital,
      'id_createur': idCreateur,
      'date_admission': dateAdmission.toIso8601String(),
      'date_cloture': dateCloture?.toIso8601String(),
      'motif_visite': motifVisite,
      'constantes_vitales': constantesVitales,
      'diagnostic': diagnostic,
      'prescription_ordonnance': prescriptionOrdonnance,
      'statut_passage': statutPassage,
    };
  }

  PassageMedical copyWith({
    String? id,
    String? idPatient,
    int? idHopital,
    int? idCreateur,
    DateTime? dateAdmission,
    DateTime? dateCloture,
    String? motifVisite,
    Map<String, dynamic>? constantesVitales,
    String? diagnostic,
    String? prescriptionOrdonnance,
    String? statutPassage,
  }) {
    return PassageMedical(
      id: id ?? this.id,
      idPatient: idPatient ?? this.idPatient,
      idHopital: idHopital ?? this.idHopital,
      idCreateur: idCreateur ?? this.idCreateur,
      dateAdmission: dateAdmission ?? this.dateAdmission,
      dateCloture: dateCloture ?? this.dateCloture,
      motifVisite: motifVisite ?? this.motifVisite,
      constantesVitales: constantesVitales ?? this.constantesVitales,
      diagnostic: diagnostic ?? this.diagnostic,
      prescriptionOrdonnance: prescriptionOrdonnance ?? this.prescriptionOrdonnance,
      statutPassage: statutPassage ?? this.statutPassage,
    );
  }
}
