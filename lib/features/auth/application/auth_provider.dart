import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_model.dart';

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
      final role = prefs.getString('user_role');
      final name = prefs.getString('user_name');
      final id = prefs.getString('user_id');

      if (token != null && role != null && name != null && id != null) {
        state = AsyncValue.data(User(id: id, name: name, role: role));
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

      final user = User(id: '1', role: role, name: 'Jean Dupont');
      
      // Save token and role in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'mock_jwt_token_123');
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_id', user.id);

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
      await prefs.remove('user_role');
      await prefs.remove('user_name');
      await prefs.remove('user_id');
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
