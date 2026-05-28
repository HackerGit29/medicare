class ExamenLaboratoire {
  final int id;
  final String idPassage;
  final int idLaborantin;
  final String typeExamen;
  final String resultats;
  final DateTime dateResultat;

  const ExamenLaboratoire({
    required this.id,
    required this.idPassage,
    required this.idLaborantin,
    required this.typeExamen,
    required this.resultats,
    required this.dateResultat,
  });

  factory ExamenLaboratoire.fromJson(Map<String, dynamic> json) {
    return ExamenLaboratoire(
      id: json['id_examen'] as int,
      idPassage: json['id_passage'] as String,
      idLaborantin: json['id_laborantin'] as int,
      typeExamen: json['type_examen'] as String,
      resultats: json['resultats'] as String,
      dateResultat: DateTime.parse(json['date_resultat'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_examen': id,
      'id_passage': idPassage,
      'id_laborantin': idLaborantin,
      'type_examen': typeExamen,
      'resultats': resultats,
      'date_resultat': dateResultat.toIso8601String(),
    };
  }

  ExamenLaboratoire copyWith({
    int? id,
    String? idPassage,
    int? idLaborantin,
    String? typeExamen,
    String? resultats,
    DateTime? dateResultat,
  }) {
    return ExamenLaboratoire(
      id: id ?? this.id,
      idPassage: idPassage ?? this.idPassage,
      idLaborantin: idLaborantin ?? this.idLaborantin,
      typeExamen: typeExamen ?? this.typeExamen,
      resultats: resultats ?? this.resultats,
      dateResultat: dateResultat ?? this.dateResultat,
    );
  }
}
