import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RouteSelector extends StatefulWidget {
  final String selectedRoute;
  final Function(String) onRouteChanged;

  const RouteSelector({
    super.key,
    required this.selectedRoute,
    required this.onRouteChanged,
  });

  @override
  State<RouteSelector> createState() => _RouteSelectorState();
}

class _RouteSelectorState extends State<RouteSelector> {
  final List<String> _routes = [
    'All Routes',
    'Route 1: Airport - City Center',
    'Route 2: Railway Station - Mall',
    'Route 3: University - Hospital',
    'Route 4: Bus Stand - Market',
    'Route 5: College - Stadium',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Filter Icon
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.filter_list,
              color: Colors.white,
              size: 20,
            ),
          ),
          
          // Route Dropdown
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.selectedRoute,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  items: _routes.map((String route) {
                    return DropdownMenuItem<String>(
                      value: route,
                      child: Text(
                        route,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      widget.onRouteChanged(newValue);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 600.ms,
    ).slideY(
      begin: 0.3,
      curve: Curves.easeOutBack,
    );
  }
}
