import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../screens/quiz_history_screen.dart';

class QuizSection extends StatefulWidget {
  const QuizSection({super.key});

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  DocumentSnapshot? quizDoc;
  int? selectedQuizIndex;
  bool answered = false; //정답 선택 여부
  bool isLoading = true;
  String? errorMessage;

  //점수 및 히스토리 저장용 리스트
  int score = 0;
  List<Map<String, dynamic>> quizHistory = [];

  @override
  void initState() {
    super.initState();
    fetchTodayQuiz();
  }

  Future<void> fetchTodayQuiz() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      quizDoc = null;
      answered = false;
      selectedQuizIndex = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('daily_quiz')
          .limit(10)
          .get();

      if (mounted && snapshot.docs.isNotEmpty) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final seed = today.hashCode;
        final random = Random(seed);
        final randomIndex = random.nextInt(snapshot.docs.length);
        final todayQuizDoc = snapshot.docs[randomIndex];

        setState(() {
          quizDoc = todayQuizDoc;
        });

        // Check if the user has already answered this quiz
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final historySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('quiz_history')
              .where('quizId', isEqualTo: todayQuizDoc.id)
              .limit(1)
              .get();

          if (historySnapshot.docs.isNotEmpty) {
            final lastAnswer = historySnapshot.docs.first.data();
            setState(() {
              answered = true;
              selectedQuizIndex = lastAnswer['selected'];
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = '퀴즈를 불러오는 데 실패했습니다.';
        });
      }
      print('퀴즈 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onSelectChoice(int index) async {
    if (answered) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = quizDoc!.data() as Map<String, dynamic>;
    final correctIndex = data['answerId'] as int?; // Make it nullable
    final isCorrect = index == correctIndex;

    setState(() {
      selectedQuizIndex = index;
      answered = true;
    });

    // Save quiz attempt to history
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('quiz_history')
        .add({
      'quizId': quizDoc!.id,
      'question': data['question'],
      'selected': index,
      'correct': correctIndex,
      'isCorrect': isCorrect,
      'explanation': data['explanation'] ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update score if correct
    if (isCorrect) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDocRef.update({'score': FieldValue.increment(1)});
      setState(() {
        score++;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? '정답입니다!' : '오답입니다...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage!),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchTodayQuiz,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (quizDoc == null) {
      return const Center(
        child: Text('오늘의 퀴즈가 없습니다.'),
      );
    }

    final data = quizDoc!.data() as Map<String, dynamic>;
    final question = data['question'];
    final choices = List<String>.from(data['choices']);
    final correctIndex = data['answerId'] as int? ?? -1; // Provide a default if null
    final explanation = data['explanation'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF4B6045)),
                  SizedBox(width: 8),
                  Text(
                    "오늘의 상식 퀴즈!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B6045),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizHistoryScreen(),
                    ),
                  );
                },
                child: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Q. $question", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 0; i < choices.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelectChoice(i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      margin: EdgeInsets.only(right: i < choices.length - 1 ? 8.0 : 0),
                      decoration: BoxDecoration(
                        color: !answered
                            ? Colors.white
                            : (i == correctIndex
                                ? Colors.green.withOpacity(0.3)
                                : (selectedQuizIndex != null && selectedQuizIndex == i
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.white)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          "${String.fromCharCode(65 + i)}. ${choices[i]}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (answered)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect(selectedQuizIndex, correctIndex) ? '정답입니다!' : '오답입니다.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCorrect(selectedQuizIndex, correctIndex) ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "설명: $explanation",
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool isCorrect(int? selected, int correct) {
    return selected == correct;
  }
}
