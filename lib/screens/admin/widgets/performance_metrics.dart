import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PerformanceMetrics extends StatelessWidget {
  final double averageRating;
  final int activeRoutes;
  final double fuelEfficiency;

  const PerformanceMetrics({
    super.key,
    required this.averageRating,
    required this.activeRoutes,
    required this.fuelEfficiency,
  });

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
              const Icon(
                Icons.analytics,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Average Rating',
                  value: averageRating.toString(),
                  subtitle: 'out of 5.0',
                  icon: Icons.star,
                  color: const Color(0xFFF59E0B),
                  progress: averageRating / 5.0,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildMetricCard(
                  title: 'Active Routes',
                  value: activeRoutes.toString(),
                  subtitle: 'routes',
                  icon: Icons.route,
                  color: const Color(0xFF10B981),
                  progress: activeRoutes / 25.0,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Fuel Efficiency
          _buildFuelEfficiencyCard(),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_gas_station,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fuel Efficiency',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '${fuelEfficiency.toStringAsFixed(1)} km/L',
                  style: const TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                
                Text(
                  'Average across fleet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Efficiency Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getEfficiencyColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getEfficiencyIcon(),
                  color: _getEfficiencyColor(),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getEfficiencyText(),
                  style: TextStyle(
                    color: _getEfficiencyColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEfficiencyColor() {
    if (fuelEfficiency >= 10.0) {
      return const Color(0xFF10B981);
    } else if (fuelEfficiency >= 7.0) {
      return const Color(0xFFF59E0B);
    } else {
      return const Color(0xFFEF4444);
    }
  }

  IconData _getEfficiencyIcon() {
    if (fuelEfficiency >= 10.0) {
      return Icons.trending_up;
    } else if (fuelEfficiency >= 7.0) {
      return Icons.trending_flat;
    } else {
      return Icons.trending_down;
    }
  }

  String _getEfficiencyText() {
    if (fuelEfficiency >= 10.0) {
      return 'Excellent';
    } else if (fuelEfficiency >= 7.0) {
      return 'Good';
    } else {
      return 'Poor';
    }
  }
}
