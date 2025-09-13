import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PassengerCountWidget extends StatefulWidget {
  final int currentCount;
  final int maxCount;
  final Function(int) onCountChanged;

  const PassengerCountWidget({
    super.key,
    required this.currentCount,
    required this.maxCount,
    required this.onCountChanged,
  });

  @override
  State<PassengerCountWidget> createState() => _PassengerCountWidgetState();
}

class _PassengerCountWidgetState extends State<PassengerCountWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.currentCount / widget.maxCount;
    final isNearCapacity = percentage > 0.8;
    
    return Container(
      padding: const EdgeInsets.all(24),
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
                    scale: isNearCapacity ? _pulseAnimation.value : 1.0,
                    child: Icon(
                      Icons.people,
                      color: _getCapacityColor(percentage),
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'Passenger Count',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCapacityColor(percentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).toInt()}% Full',
                  style: TextStyle(
                    color: _getCapacityColor(percentage),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Count Display
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getCapacityColor(percentage).withOpacity(0.1),
                    _getCapacityColor(percentage).withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: _getCapacityColor(percentage).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.currentCount.toString(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: _getCapacityColor(percentage),
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      '/ ${widget.maxCount}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          _buildProgressBar(percentage),
          
          const SizedBox(height: 20),
          
          // Control Buttons
          Row(
            children: [
              Expanded(
                child: _buildCountButton(
                  icon: Icons.remove,
                  onPressed: widget.currentCount > 0 
                      ? () => widget.onCountChanged(widget.currentCount - 1)
                      : null,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildCountButton(
                  icon: Icons.add,
                  onPressed: widget.currentCount < widget.maxCount
                      ? () => widget.onCountChanged(widget.currentCount + 1)
                      : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status Message
          Center(
            child: Text(
              _getStatusMessage(percentage),
              style: TextStyle(
                color: _getCapacityColor(percentage),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Capacity',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: _getCapacityColor(percentage),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null 
            ? const Color(0xFF3B82F6)
            : Colors.grey[300],
        foregroundColor: onPressed != null 
            ? Colors.white
            : Colors.grey[500],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Icon(icon, size: 24),
    );
  }

  Color _getCapacityColor(double percentage) {
    if (percentage < 0.5) {
      return const Color(0xFF10B981);
    } else if (percentage < 0.8) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  String _getStatusMessage(double percentage) {
    if (percentage < 0.3) {
      return 'Plenty of space available';
    } else if (percentage < 0.6) {
      return 'Good passenger load';
    } else if (percentage < 0.8) {
      return 'Getting crowded';
    } else if (percentage < 0.95) {
      return 'Almost full - be careful';
    } else {
      return 'At capacity - no more passengers';
    }
  }
}
