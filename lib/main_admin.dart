import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'l10n/app_localizations.dart';
import 'services/language_service.dart';
import 'services/mqtt_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AdminApp()));
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AdminDashboard(),
    );
  }
}

class BusData {
  final String busId;
  final double latitude;
  final double longitude;
  final int timestampMs;
  final bool isOnline;
  final double speed;
  final String route;

  BusData({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.timestampMs,
    required this.isOnline,
    required this.speed,
    required this.route,
  });

  factory BusData.fromMqttMessage(MqttLocationMessage msg) {
    return BusData(
      busId: msg.busId,
      latitude: msg.latitude,
      longitude: msg.longitude,
      timestampMs: msg.timestampMs,
      isOnline: DateTime.now().millisecondsSinceEpoch - msg.timestampMs < 30000,
      speed: 0.0, // Would be calculated from GPS data
      route: 'Route ${msg.busId.split('-')[1]}',
    );
  }
}

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final Map<String, BusData> _buses = {};
  final MqttService _mqtt = MqttService(clientId: 'admin-${DateTime.now().millisecondsSinceEpoch}');
  StreamSubscription<MqttLocationMessage>? _sub;
  String _currentLanguage = 'en';
  int _totalBuses = 0;
  int _onlineBuses = 0;
  int _offlineBuses = 0;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _startMonitoring();
  }

  Future<void> _loadLanguage() async {
    final lang = await LanguageService.getCurrentLanguage();
    setState(() {
      _currentLanguage = lang;
    });
  }

  Future<void> _startMonitoring() async {
    // Subscribe to all bus topics (in real implementation, would be dynamic)
    final testBusIds = ['PB-01-001', 'PB-01-002', 'PB-02-001', 'PB-02-002'];
    
    for (final busId in testBusIds) {
      await _mqtt.subscribeBus(busId);
    }
    
    _sub = _mqtt.locationStream.listen((msg) {
      setState(() {
        _buses[msg.busId] = BusData.fromMqttMessage(msg);
        _updateStats();
      });
    });
  }

  void _updateStats() {
    _totalBuses = _buses.length;
    _onlineBuses = _buses.values.where((bus) => bus.isOnline).length;
    _offlineBuses = _totalBuses - _onlineBuses;
  }

  Future<void> _changeLanguage(String languageCode) async {
    await LanguageService.setLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.appTitle} - Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Buses',
                    _totalBuses.toString(),
                    Colors.blue,
                    Icons.directions_bus,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Online',
                    _onlineBuses.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Offline',
                    _offlineBuses.toString(),
                    Colors.red,
                    Icons.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Fleet Status Table
            Text(
              'Fleet Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Bus ID')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Route')),
                      DataColumn(label: Text('Speed')),
                      DataColumn(label: Text('Last Update')),
                      DataColumn(label: Text('Location')),
                    ],
                    rows: _buses.values.map((bus) {
                      return DataRow(
                        cells: [
                          DataCell(Text(bus.busId)),
                          DataCell(
                            Row(
                              children: [
                                Icon(
                                  bus.isOnline ? Icons.check_circle : Icons.error,
                                  color: bus.isOnline ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(bus.isOnline ? 'Online' : 'Offline'),
                              ],
                            ),
                          ),
                          DataCell(Text(bus.route)),
                          DataCell(Text('${bus.speed.toStringAsFixed(1)} km/h')),
                          DataCell(Text(_formatTimestamp(bus.timestampMs))),
                          DataCell(Text('${bus.latitude.toStringAsFixed(4)}, ${bus.longitude.toStringAsFixed(4)}')),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestampMs) {
    final now = DateTime.now();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
