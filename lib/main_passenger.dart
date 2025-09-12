import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'l10n/app_localizations.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/ticket_purchase_screen.dart';
import 'services/language_service.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getCurrentLanguage();
    setState(() {
      _currentLanguage = lang;
    });
  }

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
        title: Text(l10n.passengerAppTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const QRScannerScreen()),
              );
            },
            tooltip: 'Scan Ticket',
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_number),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TicketPurchaseScreen(
                    busId: _busIdController.text.trim().isNotEmpty 
                        ? _busIdController.text.trim() 
                        : 'PB-01-001',
                    route: 'Route 1',
                  ),
                ),
              );
            },
            tooltip: 'Buy Ticket',
          ),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _busIdController,
                    decoration: InputDecoration(hintText: l10n.enterBusId),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _subscribe, child: Text(l10n.followBus)),
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


