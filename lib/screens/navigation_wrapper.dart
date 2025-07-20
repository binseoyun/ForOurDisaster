import 'package:flutter/material.dart';
import 'package:formydisaster/screens/disaster_alert_list_screen.dart';
import 'package:formydisaster/screens/editprofile_screen.dart';
import 'package:formydisaster/screens/map_screen.dart';
import 'home_screen.dart';
import 'call_screen.dart';
import 'manual_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  NavigationWrapperState createState() => NavigationWrapperState();
}

class NavigationWrapperState extends State<NavigationWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), //홈 탭
    const ShelterMapScreen(), //지도 탭
    const DisasterGuideScreen(), //재난 메뉴얼 탭
    const CallScreen(), //긴급연락 탭
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 75,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFFF9FBFA),
          iconSize: 30,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.warning), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.call),label: '',
            ),
          ],
        ),
      ),
    );
  }
}
