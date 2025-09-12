import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/location_service.dart';
import 'services/mqtt_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DriverApp());
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const DriverHome(),
    );
  }
}

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  final TextEditingController _busIdController = TextEditingController();
  final MqttService _mqtt = MqttService(clientId: 'driver-${DateTime.now().millisecondsSinceEpoch}');
  StreamSubscription<Position>? _sub;
  bool _tracking = false;

  @override
  void initState() {
    super.initState();
    _loadBusId();
  }

  Future<void> _loadBusId() async {
    final pref = await SharedPreferences.getInstance();
    _busIdController.text = pref.getString('busId') ?? '';
  }

  Future<void> _saveBusId(String id) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('busId', id);
  }

  Future<void> _toggleTracking() async {
    if (_tracking) {
      await _sub?.cancel();
      await _mqtt.disconnect();
      setState(() => _tracking = false);
      return;
    }
    final ok = await LocationService.ensurePermissions();
    if (!ok) return;
    final busId = _busIdController.text.trim();
    if (busId.isEmpty) return;
    await _saveBusId(busId);
    _sub = LocationService.getPositionStream().listen((pos) {
      _mqtt.publishLocation(MqttLocationMessage(
        busId: busId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
      ));
    });
    setState(() => _tracking = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _busIdController,
              decoration: const InputDecoration(labelText: 'Bus ID (e.g., PB-01-001)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(_tracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
            const SizedBox(height: 16),
            Text(_tracking ? 'Tracking active...' : 'Tracking stopped'),
          ],
        ),
      ),
    );
  }
}


