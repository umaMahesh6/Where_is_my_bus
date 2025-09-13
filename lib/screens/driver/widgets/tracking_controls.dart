import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TrackingControls extends StatelessWidget {
  final bool isTracking;
  final VoidCallback onStartTracking;
  final VoidCallback onStopTracking;

  const TrackingControls({
    super.key,
    required this.isTracking,
    required this.onStartTracking,
    required this.onStopTracking,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.gps_fixed,
                color: isTracking ? Colors.green : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Location Tracking',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isTracking 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isTracking ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: isTracking ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Tracking Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: isTracking ? onStopTracking : onStartTracking,
              icon: Icon(
                isTracking ? Icons.stop : Icons.play_arrow,
                size: 24,
              ),
              label: Text(
                isTracking ? 'Stop Tracking' : 'Start Tracking',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isTracking ? Colors.red : const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTracking 
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isTracking ? Icons.check_circle : Icons.info_outline,
                  color: isTracking ? Colors.green : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTracking 
                        ? 'Your location is being shared with passengers in real-time'
                        : 'Start tracking to share your location with passengers',
                    style: TextStyle(
                      color: isTracking ? Colors.green[700] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
