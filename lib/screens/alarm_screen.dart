import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/firestore_alert.dart';
import '../services/disaster_service.dart';
import 'map_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:formydisaster/services/check_permission.dart';
import 'package:formydisaster/services/location_service.dart'; // Add this line

class AlarmScreen extends StatefulWidget {
  final String? initialRegion;

  const AlarmScreen({super.key, this.initialRegion});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final DisasterService _disasterService = DisasterService();
  final LocationService _locationService = LocationService(); // Add this line

  List<FirestoreAlert> alerts = [];
  bool isLoading = true;
  String? errorMessage;

  String? myUserName;

  @override
  void initState() {
    super.initState();
    _loadMyUserName();
    _loadAlerts();
  }

  Future<void> _loadMyUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          // 'name' 필드가 없으면 이메일 또는 '내 이름' 기본값 사용
          myUserName = data?['name'] ?? user.email ?? '내 이름';
        });
      }
    } catch (e) {
      print('사용자 이름 로드 오류: $e');
      setState(() {
        myUserName = '내 이름';
      });
    }
  }

  Future<void> sendLocationShareRequest({
  required String targetUserId,
  required String myName,
}) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  try {
    final alertRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .collection('notifications')
        .doc(); // 자동 생성 ID

    await alertRef.set({
      'alertId': alertRef.id,
      'type': 'location_request',
      'body': '$myName 님이 위치 공유를 요청합니다.',
      'timestamp': FieldValue.serverTimestamp(),
      'fromUserId': currentUser.uid,
      'response': null,
      'shownInUI': true,
    });

    print('✅ 위치 공유 요청 전송 완료');
  } catch (e) {
    print('❌ 위치 공유 요청 실패: $e');
  }
}

  // 위치 권한 확인
  Future<bool> _checkLocationPermission() async {
    // 이미 권한이 부여되었는지 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 이미 권한이 있으면 true 반환
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    // 위치 서비스가 활성화되어 있는지 확인
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 서비스를 활성화해주세요.')));
      }
      return false;
    }

    // 권한이 거부된 상태이면 false 반환 (다시 요청하지 않음)
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.')),
        );
      }
      return false;
    }

    return true;
  }

  // 위치 공유 요청 수락 처리
  // _AlarmScreenState 내에 이 함수를 붙여넣어 완전히 교체하세요.
  Future<void> _handleAcceptLocationSharing(FirestoreAlert alert) async {
    // 함수가 호출될 때마다 고유한 ID를 부여하여 로그 추적을 쉽게 만듭니다.
    final callId = DateTime.now().millisecondsSinceEpoch;
    print('[$callId] ✅ _handleAcceptLocationSharing 실행됨');

    // await 전 mounted 상태 확인
    print('[$callId] permission 요청 전 mounted: $mounted');

    final hasPermission = await checkLocationPermission();
    print('[$callId] 📍 위치 권한 결과: $hasPermission');

    // await 후 mounted 상태 확인 (가장 중요!)
    print('[$callId] permission 요청 후 mounted: $mounted');

    if (!mounted) {
      print('[$callId] ❌ 위젯이 unmounted 상태라 더 이상 진행하지 않습니다.');
      return;
    }

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 거부되어 위치를 공유할 수 없습니다.')),
      );
      return;
    }

    print('[$callId] 🚀 권한 확인 완료, 위치 공유 로직 시작');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('[$callId] ❌ 사용자가 로그인되어 있지 않습니다.');
        return;
      }

      // Firestore 업데이트
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(alert.alertId)
          .update({
            'response': 'accepted',
            'respondedAt': FieldValue.serverTimestamp(),
          });
      print('[$callId] 💾 Firestore 상태 업데이트 완료');

      // 실시간 위치 공유 시작
      _startRealTimeLocationSharing(user.uid);
      print('[$callId] 🛰️ 실시간 위치 공유 서비스 시작');

      // 다시 한번 mounted 상태 확인 후 화면 이동
      if (mounted) {
        print('[$callId] 🗺️ 지도로 이동합니다.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShelterMapScreen()),
        );
      } else {
        print('[$callId] ❌ 화면 이동 직전, 위젯이 unmounted 상태가 되었습니다.');
      }
    } catch (e) {
      print('[$callId] 💥 위치 공유 수락 처리 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: ${e.toString()}')));
      }
    }
  }

  // 실시간 위치 공유 시작 함수 (AlarmScreen 클래스 내에 추가)
  Future<void> _startRealTimeLocationSharing(String userId) async {
    try {
      await _locationService.startSharingLocation(userId);
      print('✅ LocationService를 통해 실시간 위치 공유 시작');
    } catch (e) {
      print('❌ LocationService를 통한 위치 공유 시작 실패: $e');
    }
  }

  // 위치 공유 요청 거절 처리
  Future<void> _handleRejectLocationSharing(FirestoreAlert alert) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(alert.alertId)
          .update({
            'response': 'rejected',
            'respondedAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 공유 요청을 거절했습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: ${e.toString()}')));
      }
    }
  }

  Future<void> _loadAlerts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = '로그인이 필요합니다.';
        });
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('shownInUI', isEqualTo: true) //UI에 표시할 알림만!
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final recentAlerts = querySnapshot.docs.map((doc) {
        return FirestoreAlert.fromDoc(doc);
      }).toList();

      setState(() {
        alerts = recentAlerts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  //재난 문자 칸 하나에 들어갈 내용
  Widget _buildAlertItem(FirestoreAlert alert) {
    final isLocationRequest = alert.type == 'location_request';
    final isPendingResponse = isLocationRequest && alert.response == null;

    final displayName = myUserName ?? '알 수 없음';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isLocationRequest ? Colors.blue[50] : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isLocationRequest ? Colors.blue[200]! : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isLocationRequest)
                    const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '$displayName 님의 위치 공유를 요청',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(alert.body, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd hh:mm a').format(alert.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (isLocationRequest && alert.response != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: alert.response == 'accepted'
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.response == 'accepted' ? '수락됨' : '거절됨',
                        style: TextStyle(
                          color: alert.response == 'accepted'
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (isPendingResponse) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _handleRejectLocationSharing(alert),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('거절'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleAcceptLocationSharing(alert),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('수락'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("알림")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('오류 발생: $errorMessage'))
          : alerts.isEmpty
          ? const Center(child: Text("표시할 재난 문자가 없습니다."))
          : ListView.builder(
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertItem(alerts[index]);
              },
            ),
    );
  }
}
