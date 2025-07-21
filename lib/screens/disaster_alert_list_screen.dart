import 'package:flutter/material.dart';

class DisasterAlertListScreen extends StatefulWidget {
  const DisasterAlertListScreen({super.key});

  @override
  State<DisasterAlertListScreen> createState() =>
      _DisasterAlertListScreenState();
}

class _DisasterAlertListScreenState extends State<DisasterAlertListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("긴급 재난 문자")),
      body: Center(child: Text("재난 문자 목록")),
    );
  }
}
