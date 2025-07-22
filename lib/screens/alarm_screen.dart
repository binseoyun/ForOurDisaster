import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/firestore_alert.dart';
import '../services/disaster_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AlarmScreen extends StatefulWidget {
  final String? initialRegion;

  const AlarmScreen({super.key, this.initialRegion});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final DisasterService _disasterService = DisasterService();

  List<FirestoreAlert> alerts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
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
        final data = doc.data();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(alert.body, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              DateFormat('h:mm a').format(alert.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("긴급 재난 문자")),
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
