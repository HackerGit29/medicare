class Patient {
  final String id; 
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String genre;
  final String? groupeSanguin;
  final String? telephone;
  final DateTime creeLe;

  const Patient({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.genre,
    this.groupeSanguin,
    this.telephone,
    required this.creeLe,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id_patient'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['date_naissance'] as String),
      genre: json['genre'] as String,
      groupeSanguin: json['groupe_sanguin'] as String?,
      telephone: json['telephone'] as String?,
      creeLe: DateTime.parse(json['cree_le'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_patient': id,
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance.toIso8601String(),
      'genre': genre,
      'groupe_sanguin': groupeSanguin,
      'telephone': telephone,
      'cree_le': creeLe.toIso8601String(),
    };
  }
}
