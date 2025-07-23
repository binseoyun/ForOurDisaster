// alarm 창 용
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAlert {
  final String alertId;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool shownInUI;
  final String? region;
  final String type; // 'location_request' or other types
  final String? response; // 'accepted' or 'rejected' or null
  final String? requestFrom; // UID of the user who sent the request
  final String? requestTo; // UID of the user who received the request

  FirestoreAlert({
    required this.alertId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.shownInUI,
    required this.type,
    this.region,
    this.response,
    this.requestFrom,
    this.requestTo,
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
      timestamp: parsedTimestamp,
      shownInUI: data['shownInUI'] ?? true,
      region: data['region'],
      type: data['type'] ?? 'general',
      response: data['response'],
      requestFrom: data['requestFrom'],
      requestTo: data['requestTo'],
    );
  }
}