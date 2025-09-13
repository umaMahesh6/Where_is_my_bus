import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _orbitController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _orbitAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _orbitController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _orbitAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _orbitController,
      curve: Curves.linear,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    _orbitController.repeat();
    await _textController.forward();
    
    // Navigate to role selection after animations
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/role-selection');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _orbitController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Color(0xFF475569),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) => _buildParticle(index)),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with orbit animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbit rings
                        AnimatedBuilder(
                          animation: _orbitAnimation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(200, 200),
                              painter: OrbitPainter(
                                angle: _orbitAnimation.value,
                              ),
                            );
                          },
                        ),
                        
                        // Main logo
                        AnimatedBuilder(
                          animation: _logoAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _logoAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                      Color(0xFFEC4899),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.directions_bus,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App title with animation
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              'ORBIT LIVE',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                fontSize: 36,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 600.ms).slideY(),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Punjab Transit Revolution',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white70,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w300,
                              ),
                            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              'Real-time • Smart • Connected',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white60,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w300,
                              ),
                            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Loading indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    strokeWidth: 3,
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                ],
              ),
            ),
            
            // Bottom branding
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Punjab Government Initiative',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 4 + 2;
    final left = random.nextDouble() * 400;
    final top = random.nextDouble() * 800;
    final delay = random.nextInt(2000);
    
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).moveY(
        begin: 0,
        end: -50,
        duration: const Duration(seconds: 3),
      ).then().fadeOut(),
    );
  }
}

class OrbitPainter extends CustomPainter {
  final double angle;
  
  OrbitPainter({required this.angle});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    
    // Draw orbit rings
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius - (i * 15);
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.1 - (i * 0.03))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      
      canvas.drawCircle(center, ringRadius, paint);
    }
    
    // Draw orbiting particles
    for (int i = 0; i < 6; i++) {
      final particleAngle = angle + (i * math.pi / 3);
      final x = math.cos(particleAngle) * radius;
      final y = math.sin(particleAngle) * radius;
      
      final paint = Paint()
        ..color = const Color(0xFF6366F1).withOpacity(0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(center.dx + x, center.dy + y),
        3,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}