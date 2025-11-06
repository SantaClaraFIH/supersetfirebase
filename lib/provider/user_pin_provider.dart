import 'package:flutter/foundation.dart';

class UserPinProvider extends ChangeNotifier {
  String _pin = '';

  String get pin => _pin;

  void setPin(String pin) {
    _pin = pin;
    notifyListeners(); // Notify all listeners about the change
  }
}
