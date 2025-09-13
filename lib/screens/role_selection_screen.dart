import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/role_provider.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF334155),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Header
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: Colors.white,
                      ),
                    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      'Welcome to Orbit Live',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Choose your role to continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                // Role Cards
                Expanded(
                  child: Column(
                    children: [
                      // Passenger Card
                      _buildRoleCard(
                        context: context,
                        title: 'Passenger',
                        subtitle: 'Track buses, book tickets, and travel smart',
                        icon: Icons.person,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        onTap: () => _selectRole(context, ref, UserRole.passenger),
                        delay: 600,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Driver Card
                      _buildRoleCard(
                        context: context,
                        title: 'Driver',
                        subtitle: 'Start tracking, manage routes, and earn more',
                        icon: Icons.drive_eta,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        onTap: () => _selectRole(context, ref, UserRole.driver),
                        delay: 800,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Admin Card
                      _buildRoleCard(
                        context: context,
                        title: 'Admin',
                        subtitle: 'Monitor fleet, analyze data, and manage operations',
                        icon: Icons.admin_panel_settings,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        onTap: () => _selectRole(context, ref, UserRole.admin),
                        delay: 1000,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Footer
                Text(
                  'Punjab Government Initiative',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 1200.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(width: 20),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideX(begin: 0.3, curve: Curves.easeOut)
        .shimmer(delay: Duration(milliseconds: delay + 200), duration: 1000.ms);
  }

  void _selectRole(BuildContext context, WidgetRef ref, UserRole role) {
    ref.read(roleProvider).setRole(role);
    
    // Add haptic feedback
    // HapticFeedback.lightImpact();
    
    // Navigate to sign in
    context.go('/signin');
  }
}