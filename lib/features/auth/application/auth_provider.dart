import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/personnel_medical_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userType = prefs.getString('user_type');
      final userDataStr = prefs.getString('user_data');

      if (token != null && userType != null && userDataStr != null) {
        final Map<String, dynamic> data = jsonDecode(userDataStr);
        if (userType == 'patient') {
          state = AsyncValue.data(PatientUser(Patient.fromJson(data)));
        } else if (userType == 'personnel') {
          state = AsyncValue.data(PersonnelUser(PersonnelMedical.fromJson(data)));
        } else {
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Determine role based on email for testing purposes
      String role = 'patient';
      if (email.contains('doctor')) role = 'doctor';
      if (email.contains('nurse')) role = 'nurse';
      if (email.contains('lab')) role = 'lab_tech';
      if (email.contains('pharm')) role = 'pharmacist';

      User user;
      String userType;
      String userDataStr;

      if (role == 'patient') {
        userType = 'patient';
        final patient = Patient(
          id: 'PAT-001',
          nom: 'Dupont',
          prenom: 'Jean',
          dateNaissance: DateTime(1980, 1, 1),
          genre: 'M',
          creeLe: DateTime.now(),
        );
        user = PatientUser(patient);
        userDataStr = jsonEncode(patient.toJson());
      } else {
        userType = 'personnel';
        final personnel = PersonnelMedical(
          id: 1,
          nom: 'Martin',
          prenom: 'Claire',
          role: role,
          identifiantPro: 'PRO-1234',
        );
        user = PersonnelUser(personnel);
        userDataStr = jsonEncode(personnel.toJson());
      }
      
      // Save token and role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_jwt_token_123');
      await prefs.setString('user_type', userType);
      await prefs.setString('user_data', userDataStr);

      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_type');
      await prefs.remove('user_data');
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
