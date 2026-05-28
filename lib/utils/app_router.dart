import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/patient_screen.dart';
import '../screens/home_screen.dart';
import '../screens/doctor_screen.dart';
import '../screens/nurse_screen.dart';
import '../screens/lab_screen.dart';
import '../screens/pharmacist_screen.dart';
import '../screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/patient',
        builder: (context, state) => const PatientScreen(),
      ),
      GoRoute(
        path: '/home', // Agent d'admission
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/doctor',
        builder: (context, state) => const DoctorScreen(),
      ),
      GoRoute(
        path: '/nurse',
        builder: (context, state) => const NurseScreen(),
      ),
      GoRoute(
        path: '/lab',
        builder: (context, state) => const LabScreen(),
      ),
      GoRoute(
        path: '/pharmacist',
        builder: (context, state) => const PharmacistScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      // Logic to handle redirection based on authState
      final isAuthenticated = authState.value != null;
      final isLoggingIn = state.uri.toString() == '/login';

      if (authState.isLoading) return null;

      if (!isAuthenticated && !isLoggingIn) return '/login';

      if (isAuthenticated && isLoggingIn) {
        final role = authState.value?.role;
        switch (role) {
          case 'patient':
            return '/patient';
          case 'doctor':
            return '/doctor';
          case 'nurse':
            return '/nurse';
          case 'lab_tech':
            return '/lab';
          case 'pharmacist':
            return '/pharmacist';
          default:
            return '/home'; // Default agent role
        }
      }

      return null;
    },
  );
});
