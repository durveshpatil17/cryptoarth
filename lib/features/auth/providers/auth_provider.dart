import 'package:flutter/material.dart';
import 'package:cryptoarth/features/auth/screens/welcome_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/auth/models/user_model.dart';
import 'package:cryptoarth/features/auth/services/auth_service.dart';
import 'package:cryptoarth/core/storage/token_storage.dart';
import 'dart:async';
import 'package:cryptoarth/core/storage/persistent_storage.dart';
import 'package:cryptoarth/core/network/api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthState {
  final bool isLoading;
  final bool isCheckingSession;
  final bool isAuthenticated;
  final bool hasSeenLanding;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isCheckingSession = false,
    this.isAuthenticated = false,
    this.hasSeenLanding = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isCheckingSession,
    bool? isAuthenticated,
    bool? hasSeenLanding,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isCheckingSession: isCheckingSession ?? this.isCheckingSession,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasSeenLanding: hasSeenLanding ?? this.hasSeenLanding,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkInitialAuth();
    _listenForAuthErrors();
  }

  void _listenForAuthErrors() {
    ApiClient.authErrorStream.stream.listen((_) {
      if (mounted) logout();
    });
  }

  Future<void> _checkInitialAuth() async {
    state = state.copyWith(isCheckingSession: true);
    try {
      final token = await TokenStorage.getToken();
      final hasSeenLanding = await PersistentStorage.shouldShowLanding() == false;
      
      if (token != null) {
        final profileData = await _authService.fetchProfile();
        final user = UserModel.fromJson(profileData);
        state = state.copyWith(
          isCheckingSession: false,
          isAuthenticated: true,
          hasSeenLanding: true, 
          user: user,
          error: null,
        );
      } else {
        state = state.copyWith(isCheckingSession: false, isAuthenticated: false, hasSeenLanding: hasSeenLanding);
      }
    } catch (e) {
      await TokenStorage.deleteToken();
      state = state.copyWith(isCheckingSession: false, isAuthenticated: false, error: 'Session expired or invalid token');
    }
  }

  Future<void> setLandingSeen() async {
    await PersistentStorage.markLandingSeen();
    state = state.copyWith(hasSeenLanding: true);
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendOtp(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<bool> login(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.login(phone, otp);
      if (success) {
        final profileData = await _authService.fetchProfile();
        final user = UserModel.fromJson(profileData);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Login failed');
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signup({
    required String phone,
    required String otp,
    required String email,
    required String firstName,
    required String lastName,
    String refercode = "",
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.signup(phone, otp, email, firstName, lastName, refercode: refercode);
      if (success) {
        final profileData = await _authService.fetchProfile();
        final user = UserModel.fromJson(profileData);
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          error: null,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Signup failed');
      }
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profileData = await _authService.updateProfile(updates);
      final user = UserModel.fromJson(profileData);
      state = state.copyWith(
        isLoading: false,
        user: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> logout([BuildContext? context]) async {
    await TokenStorage.deleteToken();
    state = AuthState(); // Reset
    if (context != null && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
