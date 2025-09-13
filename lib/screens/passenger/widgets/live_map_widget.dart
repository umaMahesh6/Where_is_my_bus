import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LiveMapWidget extends StatefulWidget {
  final Position? currentPosition;
  final List<Map<String, dynamic>> buses;

  const LiveMapWidget({
    super.key,
    required this.currentPosition,
    required this.buses,
  });

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget>
    with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
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
    final center = widget.currentPosition != null
        ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
        : const LatLng(30.7046, 76.7179); // Default to Chandigarh

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: center,
        zoom: 13.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        // Tile Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.punjabtransit.orbitlive',
        ),
        
        // Current Location Marker
        if (widget.currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 40,
                height: 40,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        
        // Bus Markers
        MarkerLayer(
          markers: widget.buses.map((bus) {
            return Marker(
              point: LatLng(bus['latitude'], bus['longitude']),
              width: 50,
              height: 50,
              child: _buildBusMarker(bus),
            );
          }).toList(),
        ),
        
        // Map Controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.my_location,
                onTap: () {
                  if (widget.currentPosition != null) {
                    _mapController.move(
                      LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude),
                      15.0,
                    );
                  }
                },
              ),
              
              const SizedBox(height: 8),
              
              _buildMapControl(
                icon: Icons.zoom_in,
                onTap: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                },
              ),
              
              const SizedBox(height: 8),
              
              _buildMapControl(
                icon: Icons.zoom_out,
                onTap: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                },
              ),
            ],
          ),
        ),
        
        // Bus Info Panel
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: _buildBusInfoPanel(),
        ),
      ],
    );
  }

  Widget _buildBusMarker(Map<String, dynamic> bus) {
    return GestureDetector(
      onTap: () {
        // TODO: Show bus details
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * 0.8,
            child: Container(
              decoration: BoxDecoration(
                color: _getBusColor(bus),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getBusColor(bus).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF10B981),
          size: 20,
        ),
      ),
    ).animate().fadeIn(
      duration: 600.ms,
    ).scale(
      begin: const Offset(0.8, 0.8),
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildBusInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_bus,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Live Buses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.buses.length} active',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bus List
          ...widget.buses.take(3).map((bus) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getBusColor(bus),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bus['id'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    bus['eta'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          if (widget.buses.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${widget.buses.length - 3} more buses',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(
      delay: 800.ms,
      duration: 600.ms,
    ).slideY(
      begin: 0.3,
      curve: Curves.easeOutBack,
    );
  }

  Color _getBusColor(Map<String, dynamic> bus) {
    switch (bus['status']) {
      case 'On Time':
        return const Color(0xFF10B981);
      case 'Delayed':
        return const Color(0xFFEF4444);
      case 'Early':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
