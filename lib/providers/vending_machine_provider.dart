import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/vending_machine.dart';
import 'package:geolocator/geolocator.dart';

class VendingMachineProvider with ChangeNotifier {
  final List<VendingMachine> _machines = [
    VendingMachine(
      id: "1",
      name: "홍익대 세종캠퍼스 정문",
      location: const LatLng(36.6217, 127.0888),
      address: "세종특별자치시 조치원읍 세종로 2639",
      stock: 10,
    ),
    VendingMachine(
      id: "2",
      name: "홍익대 제1공학관",
      location: const LatLng(36.6207, 127.0882),
      address: "세종특별자치시 조치원읍 세종로 2639",
      stock: 5,
    ),
    VendingMachine(
      id: "3",
      name: "조치원역 광장",
      location: const LatLng(36.6013, 127.2960),
      address: "세종특별자치시 조치원읍 조치원로 31",
      stock: 8,
    ),
    VendingMachine(
      id: "4",
      name: "Google Headquarters",
      location: const LatLng(37.4220, -122.0841),
      address: "1600 Amphitheatre Pkwy, Mountain View",
      stock: 15,
    ),
    VendingMachine(
      id: "5",
      name: "Computer History Museum",
      location: const LatLng(37.4143, -122.0769),
      address: "1401 N Shoreline Blvd, Mountain View",
      stock: 12,
    ),
    VendingMachine(
      id: "6",
      name: "Shoreline Amphitheatre",
      location: const LatLng(37.4267, -122.0806),
      address: "1 Amphitheatre Pkwy, Mountain View",
      stock: 8,
    ),
    VendingMachine(
      id: "7",
      name: "Charleston Park",
      location: const LatLng(37.4199, -122.0870),
      address: "Charleston Rd, Mountain View",
      stock: 6,
    ),
    VendingMachine(
      id: "8",
      name: "Microsoft Silicon Valley",
      location: const LatLng(37.4170, -122.0785),
      address: "1065 La Avenida St, Mountain View",
      stock: 0,
    ),
  ];

  List<VendingMachine> get machines => _machines;

  bool purchase(String machineId) {
    final machine = _machines.firstWhere((m) => m.id == machineId);
    if (machine.stock > 0) {
      machine.stock--;
      notifyListeners();
      return true;
    }
    return false;
  }

  void returnHelmet(String machineId) {
    final machine = _machines.firstWhere((m) => m.id == machineId);
    machine.stock++;
    notifyListeners();
  }

  bool isWithinPurchaseRange(VendingMachine machine, Position currentPosition) {
    final distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      machine.location.latitude,
      machine.location.longitude,
    );

    return distance <= 50; // 50미터 이내
  }
}
