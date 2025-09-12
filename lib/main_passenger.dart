import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'services/mqtt_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PassengerApp());
}

class PassengerApp extends StatelessWidget {
  const PassengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passenger',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const PassengerHome(),
    );
  }
}

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final MapController _map = MapController();
  final MqttService _mqtt = MqttService(clientId: 'passenger-${DateTime.now().millisecondsSinceEpoch}');
  final Map<String, LatLng> _busPositions = {};
  final TextEditingController _busIdController = TextEditingController();
  StreamSubscription<MqttLocationMessage>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _subscribe() async {
    final busId = _busIdController.text.trim();
    if (busId.isEmpty) return;
    await _mqtt.subscribeBus(busId);
    _sub ??= _mqtt.locationStream.listen((msg) {
      setState(() {
        _busPositions[msg.busId] = LatLng(msg.latitude, msg.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Bus Map')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busIdController,
                    decoration: const InputDecoration(hintText: 'Enter Bus ID to follow'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _subscribe, child: const Text('Follow')),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: const MapOptions(
                initialCenter: LatLng(31.6340, 74.8723),
                initialZoom: 11,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.punjab_transit',
                ),
                MarkerLayer(
                  markers: _busPositions.entries
                      .map((e) => Marker(
                            point: e.value,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.directions_bus, color: Colors.red, size: 32),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


