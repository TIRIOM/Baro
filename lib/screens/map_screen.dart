import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/vending_machine.dart';
import '../providers/user_provider.dart';
import '../providers/vending_machine_provider.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultLocation = LatLng(36.6217, 127.0888);

  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Position? _currentPosition;

  Future<void> _moveToNearestVendingMachine() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }

    if (_currentPosition != null) {
      final machines =
          Provider.of<VendingMachineProvider>(context, listen: false).machines;

      // 현재 위치에서 가장 가까운 자판기 찾기
      VendingMachine? nearestMachine;
      double minDistance = double.infinity;

      for (var machine in machines) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          machine.location.latitude,
          machine.location.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestMachine = machine;
        }
      }

      if (nearestMachine != null) {
        // 가장 가까운 자판기로 카메라 이동
        await _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            nearestMachine.location,
            15.0,
          ),
        );

        // 마커 업데이트
        setState(() {
          _markers.clear();
          for (var machine in machines) {
            final marker = Marker(
              markerId: MarkerId(machine.id),
              position: machine.location,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                machine.id == nearestMachine!.id
                    ? BitmapDescriptor.hueYellow // 가장 가까운 자판기는 노란색
                    : machine.isAvailable
                        ? BitmapDescriptor.hueGreen
                        : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: machine.name,
                snippet: machine.id == nearestMachine.id
                    ? '가장 가까운 자판기 (재고: ${machine.stock}개)'
                    : '재고: ${machine.stock}개',
              ),
              onTap: () => _showVendingMachineDetails(machine),
            );
            _markers.add(marker);
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveToNearestVendingMachine();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 서비스가 비활성화되어 있습니다. 설정에서 활성화해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 권한이 거부되었습니다.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      if (!mounted) return;

      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치를 가져오는 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _addMarkers() {
    final machines =
        Provider.of<VendingMachineProvider>(context, listen: false).machines;

    for (var machine in machines) {
      final marker = Marker(
        markerId: MarkerId(machine.id),
        position: machine.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          machine.isAvailable
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: machine.name,
          snippet: '재고: ${machine.stock}개',
        ),
        onTap: () => _showVendingMachineDetails(machine),
      );

      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _showVendingMachineDetails(VendingMachine machine) {
    final nearestMachine = _findNearestMachine(); // 가장 가까운 자판기 찾기

    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer2<UserProvider, VendingMachineProvider>(
        builder: (context, userProvider, vendingProvider, child) {
          final bool canPurchase = userProvider.canPurchase();
          final bool isInRange = _currentPosition != null &&
              vendingProvider.isWithinPurchaseRange(machine, _currentPosition!);

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  machine.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('주소: ${machine.address}'),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      if (machine.id == nearestMachine?.id) ...[
                        const TextSpan(
                          text: '최단 거리',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: ' • ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      TextSpan(
                        text: machine.isAvailable ? '대여 가능' : '대여 불가',
                        style: TextStyle(
                          color:
                              machine.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const TextSpan(
                        text: ' • ',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '재고: ${machine.stock}개',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (userProvider.isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Text(
                    '현재 크레딧: ${userProvider.user!.credit}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !userProvider.isLoggedIn
                        ? () {
                            Navigator.pop(context); // 바텀시트 닫기
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          }
                        : (machine.isAvailable &&
                                canPurchase &&
                                !userProvider.hasRentedHelmet &&
                                isInRange)
                            ? () {
                                if (vendingProvider.purchase(machine.id)) {
                                  userProvider.purchase(machine.id);
                                  Navigator.pop(context);
                                  _showPurchaseComplete();
                                  _addMarkers();
                                }
                              }
                            : null,
                    child: Text(
                      !userProvider.isLoggedIn
                          ? '로그인하러 가기'
                          : userProvider.hasRentedHelmet
                              ? '이미 대여중입니다'
                              : !machine.isAvailable
                                  ? '재고 없음'
                                  : !canPurchase
                                      ? '크레딧 부족'
                                      : !isInRange
                                          ? '자판기에 더 가까이 가주세요'
                                          : '구매하기 (10 크레딧)',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseComplete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('구매가 완료되었습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleReturn() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vendingProvider =
        Provider.of<VendingMachineProvider>(context, listen: false);

    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('현재 위치를 확인할 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 현재 위치에서 가장 가까운 자판기 찾기
    VendingMachine? nearestMachine;
    double minDistance = double.infinity;

    for (var machine in vendingProvider.machines) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        machine.location.latitude,
        machine.location.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestMachine = machine;
      }
    }

    if (nearestMachine == null || minDistance > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반납하려면 자판기에 더 가까이 가주세요 (50m 이내)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userProvider.hasRentedHelmet &&
        userProvider.rentedFromMachineId != null) {
      vendingProvider.returnHelmet(nearestMachine.id); // 가장 가까운 자판기에 반납
      userProvider.returnHelmet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반납이 완료되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );

      _addMarkers(); // 마커 상태 업데이트
    }
  }

  // 가장 가까운 자판기를 찾는 헬퍼 메서드
  VendingMachine? _findNearestMachine() {
    if (_currentPosition == null) return null;

    final machines =
        Provider.of<VendingMachineProvider>(context, listen: false).machines;
    VendingMachine? nearestMachine;
    double minDistance = double.infinity;

    for (var machine in machines) {
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        machine.location.latitude,
        machine.location.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestMachine = machine;
      }
    }

    return nearestMachine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자판기 위치 확인하기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              if (userProvider.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapType: MapType.normal,
            markers: _markers,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('최단 거리'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('대여 가능'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('대여 불가'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: FloatingActionButton(
              heroTag: "location",
              child: const Icon(Icons.my_location),
              onPressed: () async {
                try {
                  if (_currentPosition != null) {
                    await _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude),
                        15,
                      ),
                    );
                  } else {
                    await _getCurrentLocation();
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('현재 위치로 이동하는 중 오류가 발생했습니다.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.hasRentedHelmet) {
                    return FloatingActionButton.extended(
                      heroTag: "return",
                      onPressed: _handleReturn,
                      label: const Text('헬멧 반납하기'),
                      icon: const Icon(Icons.assignment_return),
                      backgroundColor: Colors.green,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
