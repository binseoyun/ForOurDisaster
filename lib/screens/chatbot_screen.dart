import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  final Map<String, String> presetQA = {
    '대피소 위치 알려줘': '가장 가까운 대피소는 행정안전부 대피소 정보를 통해 확인하실 수 있습니다. 앱 내 지도에서 확인해보세요.',
    '폭염 시 어떻게 행동해야 해?':
        '폭염 시에는 야외 활동을 자제하고, 충분한 수분을 섭취하세요. 시원한 장소에 머무는 것이 좋습니다.',
    '긴급 연락처는 어떻게 추가해?':
        '마이페이지 탭에서 ‘긴급 연락처 추가’를 누르고 연락처를 선택하면 바로 등록됩니다. 가족, 지인 등의 위치 확인도 가능해져요.',
  };

  @override
  void initState() {
    super.initState();
    messages.add({
      'role': 'assistant',
      'content': '안녕하세요! 재난 관련 정보를 도와드릴게요.\n예: 오늘의 날씨, 대피소 위치, 폭염 시 행동요령 등',
    });
  }

  String categorizeMessage(String message) {
    message = message.toLowerCase();

    if (message.contains('날씨') ||
        message.contains('기온') ||
        message.contains('습도') ||
        message.contains('온도') ||
        message.contains('오늘')) {
      return 'weather';
    } else if (message.contains('대피소') || message.contains('위치')) {
      return 'disaster';
    } else if (message.contains('긴급') || message.contains('연락처')) {
      return 'emergency';
    } else if (message.contains('폭염') || message.contains('더위')) {
      return 'heatwave';
    } else if (message.contains('지진') || message.contains('흔들림')) {
      return 'earthquake';
    } else if (message.contains('산불') ||
        message.contains('불') ||
        message.contains('화재')) {
      return 'wildfire';
    } else if (message.contains('태풍')) {
      return 'typhoon';
    } else if (message.contains('산사태')) {
      return 'mountain';
    } else if (message.contains('침수')) {
      return 'drown';
    } else if (message.contains('호우')) {
      return 'rain';
    } else if (message.contains('눈') || message.contains('설')) {
      return 'snow';
    } else if (message.contains('교육') ||
        message.contains('훈련') ||
        message.contains('대피요령령')) {
      return 'safety';
    } else {
      return 'general';
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': text});
    });

    _controller.clear();

    // 응답 받기 (임시)
    String reply = await fetchChatbotResponse(text);

    setState(() {
      messages.add({'role': 'assistant', 'content': reply});
    });
  }

  Future<String> fetchChatbotResponse(String message) async {
    final category = categorizeMessage(message);

    if (category == 'weather') {
      return await fetchWeatherInfo(message);
    }

    //카테고리별 AI 프롬프트 설정
    final prompts = {
      'disaster': '너는 사용자의 위치에 따라 적절한 재난 대피소 정보를 제공하는 챗봇이야.', //TODO
      'emergency': '너는 앱 내에서 긴급 연락처 추가 및 사용방법에 대해 정보를 제공하는 챗봇이야야.',
      'heatwave': '너는 폭염 예방과 대처법에 대해 안내하는 챗봇이야야.',
      'earthquake': '너는 지진 상황에서 행동요령 및 대처법에 대해 안내하는 챗봇이야.',
      'wildfire': '너는 산불 및 화재 예방과 대처법에 대해 안내하는 챗봇이야야.',
      'typhoon': '너는 태풍 시 안전수칙과 대처법에 대해 안내하는 챗봇이야야.',
      'tsunami': '너는 쓰나미(해류류) 시 안전수칙과과 대처법에 대해 안내하는 챗봇이야야.',
      'snow': '너는 대설 시 대처법에 대해 안내하는 챗봇이야.',
      'rain': '너는 폭우 시 대처법에 대해 안내하는 챗봇이야.',
      'safety': '너는 재난 대비 안전 교육을 돕는 챗봇이야.',
      'general': '너는 재난 및 재해 대비 관련 정보를 알려주는 친절한 챗봇이야.',
    };

    final systemPrompt = prompts[category] ?? prompts['general'];

    final apiKey = dotenv.env['OPENAI_API_KEY'];
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages.map((m) => {'role': m['role'], 'content': m['content']}),
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      return '죄송해요. 지금은 답변을 받을 수 없어요.';
    }
  }

  Future<String> fetchWeatherInfo(String message) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weatherApiKey = dotenv.env['OPENWEATHER_API_KEY'];
      const weatherEndpoint = 'https://api.openweathermap.org/data/2.5/weather';

      final response = await http.get(
        Uri.parse(
          '$weatherEndpoint?lat=${position.latitude}&lon=${position.longitude}&appid=$weatherApiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final description = data['weather'][0]['description'];
        final temp = data['main']['temp'];
        final feelsLike = data['main']['feels_like'];

        final tempStr = temp.toStringAsFixed(1);
        final feelsLikeStr = feelsLike.toStringAsFixed(1);

        return '현재 날씨는 $description입니다. 기온은 $tempStr°C이며, 체감 온도는 $feelsLikeStr°C입니다';
      } else {
        return '죄송해요. 날씨 정보를 가져오지 못했어요.';
      }
    } catch (e) {
      return '날씨 정보를 가져오는 중 오류가 발생했어요.';
    }
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFFD0F0C0) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
        ),
        child: Text(content, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _sendPresetMessage(String question) {
    // 채팅에 질문 추가
    setState(() {
      messages.add({'role': 'user', 'content': question});
    });

    // presetQA에서 답변 가져오기
    final answer = presetQA[question] ?? '죄송해요, 답변을 찾을 수 없어요.';

    // 챗봇의 답변 추가가
    setState(() {
      messages.add({'role': 'assistant', 'content': answer});
    });
  }

  Widget _buildPresetButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: presetQA.keys.map((question) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => _sendPresetMessage(question),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFBDBDBD)),
                  ),
                ),
                child: Text(question, style: TextStyle(fontSize: 14)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('재난 챗봇')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUser = message['role'] == 'user';
                  return _buildMessageBubble(message['content'] ?? "", isUser);
                },
              ),
            ),
            //고정 질문 버튼
            _buildPresetButtons(),
            //입력창
            Divider(height: 1),
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF2E7D32)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
