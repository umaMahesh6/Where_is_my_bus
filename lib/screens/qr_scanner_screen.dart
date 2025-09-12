import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../services/ticketing_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanning = true;
  TicketData? _scannedTicket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_scannedTicket != null) {
      return _buildTicketValidation();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;
      
      try {
        final ticketData = TicketData.fromJson(json.decode(barcode.rawValue!));
        setState(() {
          _scannedTicket = ticketData;
          _isScanning = false;
        });
        break;
      } catch (e) {
        // Invalid QR code format
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid ticket QR code. Please scan a valid ticket.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTicketValidation() {
    final isValid = TicketingService.validateTicket(_scannedTicket!);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Validation'),
        backgroundColor: isValid ? Colors.green : Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      isValid ? Icons.check_circle : Icons.error,
                      size: 64,
                      color: isValid ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isValid ? 'Valid Ticket' : 'Invalid Ticket',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isValid ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_scannedTicket != null) ...[
                      Text('Ticket ID: ${_scannedTicket!.ticketId}'),
                      Text('Passenger: ${_scannedTicket!.passengerName}'),
                      Text('Phone: ${_scannedTicket!.phoneNumber}'),
                      Text('Bus: ${_scannedTicket!.busId}'),
                      Text('Route: ${_scannedTicket!.route}'),
                      Text('From: ${_scannedTicket!.from}'),
                      Text('To: ${_scannedTicket!.to}'),
                      Text('Fare: ₹${_scannedTicket!.fare}'),
                      Text('Valid until: ${_formatDateTime(_scannedTicket!.validUntil)}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _scannedTicket = null;
                        _isScanning = true;
                      });
                    },
                    child: const Text('Scan Another'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
