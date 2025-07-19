import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ShelterMapScreen extends StatefulWidget {
  const ShelterMapScreen({super.key});

  @override
  State<ShelterMapScreen> createState() => _ShelterMapScreenState();
}

class _ShelterMapScreenState extends State<ShelterMapScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(40.7128, -74.0060); // New York

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: 탭 이동 처리
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('대피소 지도', style: TextStyle(color: Colors.black)),
            Text('Precaution is better than cure.',
                style: TextStyle(color: Colors.grey, fontSize: 12))
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.black),
            onPressed: () {
              // TODO: 언어 변경
            },
          )
        ],
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 12.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.warning), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: ''),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
