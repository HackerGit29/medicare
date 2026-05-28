import 'patient_model.dart';
import 'personnel_medical_model.dart';

sealed class User {
  String get id;
  String get name;
  String get role;
}

class PatientUser extends User {
  final Patient patient;

  PatientUser(this.patient);

  @override
  String get id => patient.id;

  @override
  String get name => '${patient.prenom} ${patient.nom}';

  @override
  String get role => 'patient';
}

class PersonnelUser extends User {
  final PersonnelMedical personnel;

  PersonnelUser(this.personnel);

  @override
  String get id => personnel.id.toString();

  @override
  String get name => '${personnel.prenom} ${personnel.nom}';

  @override
  String get role => personnel.role;
}
