import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  _QuizHistoryScreenState createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late Future<Map<String, dynamic>> _quizData;

  @override
  void initState() {
    super.initState();
    _quizData = _fetchQuizData();
  }

  Future<Map<String, dynamic>> _fetchQuizData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'score': 0, 'history': []};
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final score = userDoc.data()?['score'] ?? 0;

    final historySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quiz_history')
        .orderBy('timestamp', descending: true)
        .get();

    final history = historySnapshot.docs.map((doc) => doc.data()).toList();
    return {'score': score, 'history': history};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '퀴즈 기록',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F8FA), // 밝은 배경
      body: FutureBuilder<Map<String, dynamic>>(
        future: _quizData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('데이터가 없습니다.'));
          }

          final score = snapshot.data!['score'] as int;
          final quizHistory = snapshot.data!['history'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score Section
                Container(
                  padding: const EdgeInsets.all(28),
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F0E5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          '나의 점수',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B6045),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$score점',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B6045),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Text(
                  '퀴즈 히스토리',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (quizHistory.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('아직 푼 퀴즈가 없습니다.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quizHistory.length,
                    itemBuilder: (context, index) {
                      final item = quizHistory[index];
                      final isCorrect = item['isCorrect'] as bool;
                      final selected = item['selected'] as int? ?? 0;
                      final correct = item['correct'] as int? ?? 0;
                      final question = item['question'] ?? '';
                      final explanation = item['explanation'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isCorrect ? Icons.check_circle : Icons.cancel,
                                    color: isCorrect ? Colors.green : Colors.red,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Q. $question',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    '내 답: ',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    String.fromCharCode(65 + selected),
                                    style: TextStyle(
                                      color: isCorrect ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '정답: ',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    String.fromCharCode(65 + correct),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              if (explanation.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    '설명: $explanation',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
