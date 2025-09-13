import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoiceCommandsWidget extends StatefulWidget {
  final bool isListening;
  final VoidCallback onStartListening;

  const VoiceCommandsWidget({
    super.key,
    required this.isListening,
    required this.onStartListening,
  });

  @override
  State<VoiceCommandsWidget> createState() => _VoiceCommandsWidgetState();
}

class _VoiceCommandsWidgetState extends State<VoiceCommandsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(VoiceCommandsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isListening ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.mic,
                      color: widget.isListening 
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF3B82F6),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Voice Commands',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isListening 
                      ? const Color(0xFFEF4444).withOpacity(0.1)
                      : const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isListening ? 'LISTENING' : 'READY',
                  style: TextStyle(
                    color: widget.isListening 
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Voice Button
          Center(
            child: GestureDetector(
              onTap: widget.onStartListening,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isListening ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.isListening
                              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                              : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isListening 
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF3B82F6)).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Text
          Center(
            child: Text(
              widget.isListening 
                  ? 'Listening... Speak now'
                  : 'Tap to start voice commands',
              style: TextStyle(
                color: widget.isListening 
                    ? const Color(0xFFEF4444)
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Available Commands
          _buildCommandsList(),
        ],
      ),
    );
  }

  Widget _buildCommandsList() {
    final commands = [
      {'command': 'Start tracking', 'description': 'Begin location sharing'},
      {'command': 'Stop tracking', 'description': 'End location sharing'},
      {'command': 'Passenger count', 'description': 'Hear current count'},
      {'command': 'Earnings', 'description': 'Check today\'s earnings'},
      {'command': 'Route', 'description': 'Current route info'},
      {'command': 'Help', 'description': 'List all commands'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Commands:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 12),
        
        ...commands.map((cmd) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"${cmd['command']}"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ),
                Text(
                  cmd['description']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
