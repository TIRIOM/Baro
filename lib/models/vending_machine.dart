import 'package:google_maps_flutter/google_maps_flutter.dart';

class VendingMachine {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  int stock;

  bool get isAvailable => stock > 0;

  VendingMachine({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.stock,
  });
}
