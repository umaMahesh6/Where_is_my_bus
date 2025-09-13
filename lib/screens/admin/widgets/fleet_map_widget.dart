import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FleetMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> fleetData;

  const FleetMapWidget({
    super.key,
    required this.fleetData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.map,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Fleet Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${fleetData.length} buses',
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Map
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: FlutterMap(
                options: MapOptions(
                  center: const LatLng(30.7046, 76.7179), // Chandigarh
                  zoom: 11.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.punjabtransit.orbitlive',
                  ),
                  
                  // Bus Markers
                  MarkerLayer(
                    markers: _buildBusMarkers(),
                  ),
                  
                  // Legend
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _buildLegend(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildBusMarkers() {
    return fleetData.map((bus) {
      final isOnline = bus['status'] == 'Online';
      final color = isOnline ? Colors.green : Colors.red;
      
      return Marker(
        point: LatLng(
          30.7046 + (0.01 * (fleetData.indexOf(bus) * 0.1 - 0.5)),
          76.7179 + (0.01 * (fleetData.indexOf(bus) * 0.1 - 0.5)),
        ),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            // TODO: Show bus details
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            color: Colors.green,
            label: 'Online',
            count: fleetData.where((bus) => bus['status'] == 'Online').length,
          ),
          const SizedBox(height: 8),
          _buildLegendItem(
            color: Colors.red,
            label: 'Offline',
            count: fleetData.where((bus) => bus['status'] == 'Offline').length,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($count)',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
