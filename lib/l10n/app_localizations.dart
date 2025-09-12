import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('pa', ''),
    Locale('hi', ''),
  ];

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get driverAppTitle => _localizedValues[locale.languageCode]!['driverAppTitle']!;
  String get passengerAppTitle => _localizedValues[locale.languageCode]!['passengerAppTitle']!;
  String get busId => _localizedValues[locale.languageCode]!['busId']!;
  String get busIdHint => _localizedValues[locale.languageCode]!['busIdHint']!;
  String get startTracking => _localizedValues[locale.languageCode]!['startTracking']!;
  String get stopTracking => _localizedValues[locale.languageCode]!['stopTracking']!;
  String get trackingActive => _localizedValues[locale.languageCode]!['trackingActive']!;
  String get trackingStopped => _localizedValues[locale.languageCode]!['trackingStopped']!;
  String get followBus => _localizedValues[locale.languageCode]!['followBus']!;
  String get enterBusId => _localizedValues[locale.languageCode]!['enterBusId']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get punjabi => _localizedValues[locale.languageCode]!['punjabi']!;
  String get hindi => _localizedValues[locale.languageCode]!['hindi']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get permissionDenied => _localizedValues[locale.languageCode]!['permissionDenied']!;
  String get locationServiceDisabled => _localizedValues[locale.languageCode]!['locationServiceDisabled']!;
  String get connecting => _localizedValues[locale.languageCode]!['connecting']!;
  String get connected => _localizedValues[locale.languageCode]!['connected']!;
  String get disconnected => _localizedValues[locale.languageCode]!['disconnected']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Punjab Transit',
      'driverAppTitle': 'Driver Tracking',
      'passengerAppTitle': 'Live Bus Map',
      'busId': 'Bus ID',
      'busIdHint': 'e.g., PB-01-001',
      'startTracking': 'Start Tracking',
      'stopTracking': 'Stop Tracking',
      'trackingActive': 'Tracking active...',
      'trackingStopped': 'Tracking stopped',
      'followBus': 'Follow Bus',
      'enterBusId': 'Enter Bus ID to follow',
      'language': 'Language',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिन्दी',
      'english': 'English',
      'permissionDenied': 'Location permission denied',
      'locationServiceDisabled': 'Location service is disabled',
      'connecting': 'Connecting...',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
    },
    'pa': {
      'appTitle': 'ਪੰਜਾਬ ਟ੍ਰਾਂਜ਼ਿਟ',
      'driverAppTitle': 'ਡਰਾਈਵਰ ਟ੍ਰੈਕਿੰਗ',
      'passengerAppTitle': 'ਲਾਈਵ ਬੱਸ ਮੈਪ',
      'busId': 'ਬੱਸ ਆਈਡੀ',
      'busIdHint': 'ਜਿਵੇਂ, PB-01-001',
      'startTracking': 'ਟ੍ਰੈਕਿੰਗ ਸ਼ੁਰੂ ਕਰੋ',
      'stopTracking': 'ਟ੍ਰੈਕਿੰਗ ਬੰਦ ਕਰੋ',
      'trackingActive': 'ਟ੍ਰੈਕਿੰਗ ਚਲ ਰਹੀ ਹੈ...',
      'trackingStopped': 'ਟ੍ਰੈਕਿੰਗ ਬੰਦ ਹੈ',
      'followBus': 'ਬੱਸ ਫੌਲੋ ਕਰੋ',
      'enterBusId': 'ਫੌਲੋ ਕਰਨ ਲਈ ਬੱਸ ਆਈਡੀ ਦਰਜ ਕਰੋ',
      'language': 'ਭਾਸ਼ਾ',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिन्दी',
      'english': 'English',
      'permissionDenied': 'ਲੋਕੇਸ਼ਨ ਇਜਾਜ਼ਤ ਨਹੀਂ ਮਿਲੀ',
      'locationServiceDisabled': 'ਲੋਕੇਸ਼ਨ ਸਰਵਿਸ ਬੰਦ ਹੈ',
      'connecting': 'ਕਨੈਕਟ ਹੋ ਰਿਹਾ ਹੈ...',
      'connected': 'ਕਨੈਕਟ ਹੋ ਗਿਆ',
      'disconnected': 'ਡਿਸਕਨੈਕਟ ਹੋ ਗਿਆ',
    },
    'hi': {
      'appTitle': 'पंजाब ट्रांजिट',
      'driverAppTitle': 'ड्राइवर ट्रैकिंग',
      'passengerAppTitle': 'लाइव बस मैप',
      'busId': 'बस आईडी',
      'busIdHint': 'जैसे, PB-01-001',
      'startTracking': 'ट्रैकिंग शुरू करें',
      'stopTracking': 'ट्रैकिंग बंद करें',
      'trackingActive': 'ट्रैकिंग चल रही है...',
      'trackingStopped': 'ट्रैकिंग बंद है',
      'followBus': 'बस फॉलो करें',
      'enterBusId': 'फॉलो करने के लिए बस आईडी दर्ज करें',
      'language': 'भाषा',
      'punjabi': 'ਪੰਜਾਬੀ',
      'hindi': 'हिन्दी',
      'english': 'English',
      'permissionDenied': 'लोकेशन अनुमति नहीं मिली',
      'locationServiceDisabled': 'लोकेशन सेवा बंद है',
      'connecting': 'कनेक्ट हो रहा है...',
      'connected': 'कनेक्ट हो गया',
      'disconnected': 'डिसकनेक्ट हो गया',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pa', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
