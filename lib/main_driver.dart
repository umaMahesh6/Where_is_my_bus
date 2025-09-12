import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadBusId();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getCurrentLanguage();
    setState(() {
      _currentLanguage = lang;
    });
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

  Future<void> _changeLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.driverAppTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'en', child: Text(l10n.english)),
              PopupMenuItem(value: 'pa', child: Text(l10n.punjabi)),
              PopupMenuItem(value: 'hi', child: Text(l10n.hindi)),
            ],
            child: const Icon(Icons.language),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _busIdController,
              decoration: InputDecoration(labelText: '${l10n.busId} (${l10n.busIdHint})'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(_tracking ? l10n.stopTracking : l10n.startTracking),
            ),
            const SizedBox(height: 16),
            Text(_tracking ? l10n.trackingActive : l10n.trackingStopped),
          ],
        ),
      ),
    );
  }
}


