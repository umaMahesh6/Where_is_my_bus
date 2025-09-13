import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class RoleNotifier extends ChangeNotifier {
  UserRole _role = UserRole.passenger;
  
  UserRole get role => _role;
  
  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }
}

final roleProvider = Provider<RoleNotifier>((ref) {
  return RoleNotifier();
});