import 'dart:convert';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketData {
  final String ticketId;
  final String busId;
  final String route;
  final String from;
  final String to;
  final double fare;
  final DateTime purchaseTime;
  final DateTime validUntil;
  final String passengerName;
  final String passengerPhone;

  TicketData({
    required this.ticketId,
    required this.busId,
    required this.route,
    required this.from,
    required this.to,
    required this.fare,
    required this.purchaseTime,
    required this.validUntil,
    required this.passengerName,
    required this.passengerPhone,
  });

  Map<String, dynamic> toJson() => {
    'ticketId': ticketId,
    'busId': busId,
    'route': route,
    'from': from,
    'to': to,
    'fare': fare,
    'purchaseTime': purchaseTime.millisecondsSinceEpoch,
    'validUntil': validUntil.millisecondsSinceEpoch,
    'passengerName': passengerName,
    'passengerPhone': passengerPhone,
  };

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      ticketId: json['ticketId'],
      busId: json['busId'],
      route: json['route'],
      from: json['from'],
      to: json['to'],
      fare: json['fare'].toDouble(),
      purchaseTime: DateTime.fromMillisecondsSinceEpoch(json['purchaseTime']),
      validUntil: DateTime.fromMillisecondsSinceEpoch(json['validUntil']),
      passengerName: json['passengerName'],
      passengerPhone: json['passengerPhone'],
    );
  }

  String toQRString() => json.encode(toJson());
}

class TicketingService {
  static String generateTicketId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(9999).toString().padLeft(4, '0');
    return 'TKT-$timestamp-$randomNum';
  }

  static TicketData createTicket({
    required String busId,
    required String route,
    required String from,
    required String to,
    required double fare,
    required String passengerName,
    required String passengerPhone,
  }) {
    final now = DateTime.now();
    return TicketData(
      ticketId: generateTicketId(),
      busId: busId,
      route: route,
      from: from,
      to: to,
      fare: fare,
      purchaseTime: now,
      validUntil: now.add(const Duration(hours: 2)),
      passengerName: passengerName,
      passengerPhone: passengerPhone,
    );
  }

  static Future<bool> initiateUPIPayment({
    required String amount,
    required String merchantId,
    required String transactionId,
  }) async {
    // UPI payment URL format
    final upiUrl = 'upi://pay?pa=$merchantId&pn=Punjab%20Transit&tr=$transactionId&am=$amount&cu=INR&tn=Bus%20Ticket';
    
    try {
      final uri = Uri.parse(upiUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> initiatePhonePePayment({
    required String amount,
    required String transactionId,
  }) async {
    // PhonePe payment URL
    final phonePeUrl = 'phonepe://pay?amount=$amount&transactionId=$transactionId';
    
    try {
      final uri = Uri.parse(phonePeUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> initiateGPayPayment({
    required String amount,
    required String transactionId,
  }) async {
    // Google Pay payment URL
    final gpayUrl = 'gpay://pay?amount=$amount&transactionId=$transactionId';
    
    try {
      final uri = Uri.parse(gpayUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool validateTicket(TicketData ticket) {
    return DateTime.now().isBefore(ticket.validUntil);
  }

  static String getFareForRoute(String route, String from, String to) {
    // Mock fare calculation based on route and distance
    final routeFares = {
      'Route 1': {'Amritsar': 20.0, 'Ludhiana': 50.0, 'Jalandhar': 30.0},
      'Route 2': {'Ludhiana': 25.0, 'Patiala': 40.0, 'SAS Nagar': 35.0},
      'Route 3': {'Jalandhar': 15.0, 'Amritsar': 30.0, 'Pathankot': 60.0},
    };
    
    return routeFares[route]?[to]?.toString() ?? '25.0';
  }
}
