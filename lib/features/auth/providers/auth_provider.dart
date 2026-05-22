import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthStateData {
  final bool isLoading;
  final String? error;
  
  AuthStateData({this.isLoading = false, this.error});
}

class AuthNotifier extends Notifier<AuthStateData> {
  @override
  AuthStateData build() {
    return AuthStateData();
  }

  Future<void> login(String email, String password) async {
    state = AuthStateData(isLoading: true);
    try {
      await ref.read(authServiceProvider).signIn(email, password).timeout(const Duration(seconds: 15));
      state = AuthStateData(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthStateData(isLoading: false, error: e.message ?? 'An error occurred during login.');
    } catch (e) {
      state = AuthStateData(isLoading: false, error: 'Unexpected error: $e');
    }
  }

  Future<void> signUp(String email, String password) async {
    state = AuthStateData(isLoading: true);
    try {
      await ref.read(authServiceProvider).signUp(email, password).timeout(const Duration(seconds: 15));
      state = AuthStateData(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = AuthStateData(isLoading: false, error: e.message ?? 'An error occurred during sign up.');
    } catch (e) {
      state = AuthStateData(isLoading: false, error: 'Unexpected error: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    state = AuthStateData(isLoading: true);
    try {
      await ref.read(authServiceProvider).resetPassword(email).timeout(const Duration(seconds: 15));
      state = AuthStateData(isLoading: false, error: 'Success! Please check your email.');
    } on FirebaseAuthException catch (e) {
      state = AuthStateData(isLoading: false, error: e.message ?? 'An error occurred.');
    } catch (e) {
      state = AuthStateData(isLoading: false, error: 'Unexpected error: $e');
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).signOut().timeout(const Duration(seconds: 10));
  }

  void clearError() {
    state = AuthStateData(isLoading: state.isLoading);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthStateData>(() {
  return AuthNotifier();
});
