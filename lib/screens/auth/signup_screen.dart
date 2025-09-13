import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/role_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).state;
    final selectedRole = ref.watch(roleProvider).role;

    // Navigate to appropriate screen after successful authentication
    ref.listen<AuthNotifier>(authProvider, (previous, next) {
      if (next.state.isAuthenticated && !next.state.isLoading) {
        switch (next.state.userRole) {
          case UserRole.passenger:
            context.go('/passenger');
            break;
          case UserRole.driver:
            context.go('/driver');
            break;
          case UserRole.admin:
            context.go('/admin');
            break;
          case null:
            context.go('/role-selection');
            break;
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getGradientColors(selectedRole),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/role-selection'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: const CircleBorder(),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(),
                
                const SizedBox(height: 20),
                
                // Header
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _getGradientColors(selectedRole).take(2).toList(),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getRoleColor(selectedRole).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getRoleIcon(selectedRole),
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Join as ${_getRoleTitle(selectedRole)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Sign up form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getRoleColor(selectedRole),
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Name field
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 700.ms, duration: 400.ms).slideX(),
                        
                        const SizedBox(height: 16),
                        
                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 800.ms, duration: 400.ms).slideX(),
                        
                        const SizedBox(height: 16),
                        
                        // Password field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 900.ms, duration: 400.ms).slideX(),
                        
                        const SizedBox(height: 16),
                        
                        // Confirm Password field
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          icon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 1000.ms, duration: 400.ms).slideX(),
                        
                        const SizedBox(height: 24),
                        
                        // Sign up button
                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getRoleColor(selectedRole),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ).animate().fadeIn(delay: 1100.ms, duration: 400.ms).slideY(),
                        
                        const SizedBox(height: 16),
                        
                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            TextButton(
                              onPressed: () => context.go('/signin'),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: _getRoleColor(selectedRole),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
                        
                        const SizedBox(height: 16),
                        
                        // Skip button
                        TextButton(
                          onPressed: () => _skipAuthentication(),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(delay: 1300.ms, duration: 400.ms),
                        
                        // Error message
                        if (authState.error != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[600], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _getRoleColor(ref.watch(roleProvider).role), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      // Accept any credentials for mock authentication
      ref.read(authProvider).signUp(
        _nameController.text.trim().isEmpty ? 'Demo User' : _nameController.text.trim(),
        _emailController.text.trim().isEmpty ? 'demo@example.com' : _emailController.text.trim(),
        _passwordController.text.isEmpty ? 'password123' : _passwordController.text,
        ref.read(roleProvider).role,
      );
    }
  }

  void _skipAuthentication() {
    // Skip authentication and go directly to role-based screen
    final selectedRole = ref.read(roleProvider).role;
    switch (selectedRole) {
      case UserRole.passenger:
        context.go('/passenger');
        break;
      case UserRole.driver:
        context.go('/driver');
        break;
      case UserRole.admin:
        context.go('/admin');
        break;
    }
  }

  List<Color> _getGradientColors(UserRole role) {
    switch (role) {
      case UserRole.passenger:
        return [const Color(0xFF10B981), const Color(0xFF059669), const Color(0xFFF3F4F6)];
      case UserRole.driver:
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB), const Color(0xFFF3F4F6)];
      case UserRole.admin:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED), const Color(0xFFF3F4F6)];
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.passenger:
        return const Color(0xFF10B981);
      case UserRole.driver:
        return const Color(0xFF3B82F6);
      case UserRole.admin:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.passenger:
        return Icons.person;
      case UserRole.driver:
        return Icons.drive_eta;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleTitle(UserRole role) {
    switch (role) {
      case UserRole.passenger:
        return 'Passenger';
      case UserRole.driver:
        return 'Driver';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}