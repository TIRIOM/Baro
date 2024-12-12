import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  int credit;
  bool hasRentedHelmet;
  String? rentedFromMachineId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.credit,
    this.hasRentedHelmet = false,
    this.rentedFromMachineId,
  });
}

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool get isLoggedIn => _user != null;

  // Mock 사용자 데이터 - 테스트 계정 추가
  final Map<String, String> _mockCredentials = {
    'test@test.com': '123456', // 테스트 계정 추가
  };

  bool loginWithCredentials(String email, String password) {
    if (_mockCredentials[email] == password) {
      _user = User(
        id: '1',
        name: email == 'test@test.com'
            ? '테스트 사용자'
            : email.split('@')[0], // 테스트 계정일 경우 이름 고정
        email: email,
        credit: 100,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  bool canPurchase() {
    return _user != null && _user!.credit >= 10;
  }

  void purchase(String machineId) {
    if (canPurchase()) {
      _user!.credit -= 10;
      _user!.hasRentedHelmet = true;
      _user!.rentedFromMachineId = machineId;
      notifyListeners();
    }
  }

  void returnHelmet() {
    if (_user != null && _user!.hasRentedHelmet) {
      _user!.hasRentedHelmet = false;
      _user!.rentedFromMachineId = null;
      notifyListeners();
    }
  }

  bool signup({
    required String name,
    required String email,
    required String password,
  }) {
    if (_mockCredentials.containsKey(email)) {
      return false;
    }

    _mockCredentials[email] = password;
    _user = User(
      id: DateTime.now().toString(),
      name: name,
      email: email,
      credit: 100,
    );
    notifyListeners();
    return true;
  }

  bool get hasRentedHelmet => _user?.hasRentedHelmet ?? false;
  String? get rentedFromMachineId => _user?.rentedFromMachineId;
}
