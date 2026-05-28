class PersonnelMedical {
  final int id;
  final int? idHopital;
  final String nom;
  final String prenom;
  final String role; 
  final String? identifiantPro;
  final String? login;
  final bool estActif;

  const PersonnelMedical({
    required this.id,
    this.idHopital,
    required this.nom,
    required this.prenom,
    required this.role,
    this.identifiantPro,
    this.login,
    this.estActif = true,
  });

  factory PersonnelMedical.fromJson(Map<String, dynamic> json) {
    return PersonnelMedical(
      id: json['id_personnel'] as int,
      idHopital: json['id_hopital'] as int?,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      role: json['role'] as String,
      identifiantPro: json['identifiant_pro'] as String?,
      login: json['login'] as String?,
      estActif: json['est_actif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_personnel': id,
      'id_hopital': idHopital,
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'identifiant_pro': identifiantPro,
      'login': login,
      'est_actif': estActif,
    };
  }
}
