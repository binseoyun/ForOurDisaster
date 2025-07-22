// alarm 창 용
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAlert {
  final String alertId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool shownInUI;
  final String? region;

  FirestoreAlert({
    required this.alertId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.shownInUI,
    this.region,
  });

  factory FirestoreAlert.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawTimestamp = data['timestamp'];
    DateTime parsedTimestamp;

    if (rawTimestamp is Timestamp) {
      parsedTimestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedTimestamp = rawTimestamp;
    } else {
      parsedTimestamp = DateTime.now(); // 또는 원하는 기본값
    }

    return FirestoreAlert(
      alertId: doc.id,
      title: data['title'] ?? '', 
      body: data['body'] ?? '', 
      timestamp: (data['timestamp'] as Timestamp).toDate(), 
      shownInUI: data['shownInUI'] ?? true,
      region: data['region'],
    );
  }
}