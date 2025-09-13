import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { passenger, driver, admin }

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? userEmail;
  final String? error;
  final UserRole? userRole;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userEmail,
    this.error,
    this.userRole,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? userEmail,
    String? error,
    UserRole? userRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      error: error ?? this.error,
      userRole: userRole ?? this.userRole,
    );
  }
}

class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState();
  
  AuthState get state => _state;
  
  AuthNotifier() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      final userEmail = prefs.getString('userEmail');
      final userRoleString = prefs.getString('userRole');
      
      UserRole? userRole;
      if (userRoleString != null) {
        userRole = UserRole.values.firstWhere(
          (role) => role.name == userRoleString,
          orElse: () => UserRole.passenger,
        );
      }
      
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: isAuthenticated,
        userEmail: userEmail,
        userRole: userRole,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Failed to check authentication status',
      );
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password, UserRole role) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication - accept any credentials
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);
      await prefs.setString('userRole', role.name);
      
      _state = _state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
        userRole: role,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Sign in failed. Please try again.',
      );
      notifyListeners();
    }
  }

  Future<void> signUp(String name, String email, String password, UserRole role) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock registration - in real app, register with backend
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userRole', role.name);
        
        _state = _state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          userEmail: email,
          userRole: role,
        );
        notifyListeners();
      } else {
        _state = _state.copyWith(
          isLoading: false,
          error: 'Please fill all fields',
        );
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Sign up failed. Please try again.',
      );
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _state = const AuthState();
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: 'Sign out failed',
      );
      notifyListeners();
    }
  }
}

final authProvider = Provider<AuthNotifier>((ref) {
  return AuthNotifier();
});