import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class QuizSection extends StatefulWidget {
  const QuizSection({super.key});

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  DocumentSnapshot? quizDoc;
  int? selectedQuizIndex;

  @override
  void initState() {
    super.initState();
    fecthTodayQuiz();
  }

  Future<void> fecthTodayQuiz() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('daily_quiz')
        .limit(10) //최대 10개만 가져오도록 제한한
        .get();

    if (snapshot.docs.isNotEmpty) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final seed = today.hashCode;
      final random = Random(seed);
      final randomIndex = random.nextInt(snapshot.docs.length);

      setState(() {
        quizDoc = snapshot.docs[randomIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizDoc == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = quizDoc!.data() as Map<String, dynamic>;
    final question = data['question'];
    final choices = List<String>.from(data['choices']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F5DB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "오늘의 상식 퀴즈!",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text("Q. $question", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          for (int i = 0; i < choices.length; i++)
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedQuizIndex = i;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: selectedQuizIndex == i
                      ? Color(0xFFE7EBD3)
                      : Color(0xFFCCE2C1),
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${String.fromCharCode(65 + i)}. ${choices[i]}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
