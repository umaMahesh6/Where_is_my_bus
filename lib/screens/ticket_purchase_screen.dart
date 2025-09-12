import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/ticketing_service.dart';

class TicketPurchaseScreen extends StatefulWidget {
  final String busId;
  final String route;

  const TicketPurchaseScreen({
    super.key,
    required this.busId,
    required this.route,
  });

  @override
  State<TicketPurchaseScreen> createState() => _TicketPurchaseScreenState();
}

class _TicketPurchaseScreenState extends State<TicketPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  
  String _selectedPaymentMethod = 'upi';
  TicketData? _purchasedTicket;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromController.text = 'Amritsar';
    _toController.text = 'Ludhiana';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_purchasedTicket != null) {
      return _buildTicketDisplay();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.appTitle} - Buy Ticket'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journey Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _fromController,
                              decoration: const InputDecoration(
                                labelText: 'From',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter departure city';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _toController,
                              decoration: const InputDecoration(
                                labelText: 'To',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter destination city';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Bus: ${widget.busId}'),
                      Text('Route: ${widget.route}'),
                      Text('Fare: ₹${TicketingService.getFareForRoute(widget.route, _fromController.text, _toController.text)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passenger Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<String>(
                        title: const Text('UPI'),
                        subtitle: const Text('Pay using UPI apps'),
                        value: 'upi',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('PhonePe'),
                        subtitle: const Text('Pay using PhonePe'),
                        value: 'phonepe',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Google Pay'),
                        subtitle: const Text('Pay using Google Pay'),
                        value: 'gpay',
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _purchaseTicket,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text('Buy Ticket - ₹${TicketingService.getFareForRoute(widget.route, _fromController.text, _toController.text)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _purchaseTicket() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create ticket
      final ticket = TicketingService.createTicket(
        busId: widget.busId,
        route: widget.route,
        from: _fromController.text,
        to: _toController.text,
        fare: double.parse(TicketingService.getFareForRoute(widget.route, _fromController.text, _toController.text)),
        passengerName: _nameController.text,
        passengerPhone: _phoneController.text,
      );
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, would integrate with actual payment gateway
      bool paymentSuccess = false;
      
      switch (_selectedPaymentMethod) {
        case 'upi':
          paymentSuccess = await TicketingService.initiateUPIPayment(
            amount: ticket.fare.toString(),
            merchantId: 'punjabtransit@paytm',
            transactionId: ticket.ticketId,
          );
          break;
        case 'phonepe':
          paymentSuccess = await TicketingService.initiatePhonePePayment(
            amount: ticket.fare.toString(),
            transactionId: ticket.ticketId,
          );
          break;
        case 'gpay':
          paymentSuccess = await TicketingService.initiateGPayPayment(
            amount: ticket.fare.toString(),
            transactionId: ticket.ticketId,
          );
          break;
      }
      
      if (paymentSuccess) {
        setState(() {
          _purchasedTicket = ticket;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTicketDisplay() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Ticket'),
        backgroundColor: Colors.green,
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
                    Text(
                      'Your Digital Ticket',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: _purchasedTicket!.toQRString(),
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ticket ID: ${_purchasedTicket!.ticketId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Bus: ${_purchasedTicket!.busId}'),
                    Text('Route: ${_purchasedTicket!.route}'),
                    Text('From: ${_purchasedTicket!.from}'),
                    Text('To: ${_purchasedTicket!.to}'),
                    Text('Fare: ₹${_purchasedTicket!.fare}'),
                    Text('Valid until: ${_formatDateTime(_purchasedTicket!.validUntil)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
