import 'package:flutter/material.dart';
import 'package:formydisaster/screens/disaster_details/earthquake_detail.dart';
import 'package:formydisaster/screens/disaster_details/extremehot_detail.dart';
import 'package:formydisaster/screens/disaster_details/flooded_detail.dart';
import 'package:formydisaster/screens/disaster_details/heavyrain_detail.dart';
import 'package:formydisaster/screens/disaster_details/landslide_detail.dart';
import 'package:formydisaster/screens/disaster_details/snow_detail.dart';
//각 disaster_detail.dart이 폴더내용을 import 해서 onTap 연결
//가뭄 연결
import 'disaster_details/wind_detail.dart'; //강풍 연결

class DisasterGuideScreen extends StatefulWidget {
  const DisasterGuideScreen({super.key});

  @override
  State<DisasterGuideScreen> createState() => _DisasterGuideScreenState();
}

//UI 관리하는 클래스
class _DisasterGuideScreenState extends State<DisasterGuideScreen> {
  final TextEditingController _searchController = TextEditingController(); //검색 입력값을 관리하기 위한 컨트롤러, 검색창에 입력된 값을 실시간 추적 가능

  // 재난 데이터 전체 리스트
  final List<Map<String, String>> _allDisasters = [           
  {'title': '대설', 'icon': '❄️'},          
  {'title': '산사태', 'icon': '🌄'},                 
  {'title': '지진', 'icon': '🌍'},             
  {'title': '침수', 'icon': '🚤'},         
  {'title': '태풍', 'icon': '🌀'},          
  {'title': '폭염', 'icon': '🔥'},                 
  {'title': '호우', 'icon': '🌧️'},          
        
  ];

  String _searchQuery = ''; //사용자가 입력한 검색어를 저장하는 문자열

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> filteredDisasters = _allDisasters.where((disaster) { //리스트 필터링
      final title = disaster['title']!.toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('자연 재해 행동 요령'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            // Figma 스타일 검색창
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search disaster',
                    hintStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B0B0)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFB0B0B0), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFB0B0B0), width: 1.2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            // 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filteredDisasters.length,
                itemBuilder: (context, index) {
                  final disaster = filteredDisasters[index];

                  //Container를 GestureDetecotr로 감싸고, onTap에서 disaster['title'] 값을 기준으로 분기해서 각 상세 페이지로 이동하도록 구현
                  return GestureDetector(
                    onTap: () {
                      switch (disaster['title']) {
                        case '대설':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SnowDetailPage()));
                          break;
                        case '산사태':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LandslideDetail()));
                          break;
                        case '지진':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EarthquakeDetailPage()));
                          break;
                        case '침수':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FloodedDetailPage()));
                          break;
                        case '태풍':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const WindDetailPage()));
                          break;
                        case '폭염':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExtremehotDetailPage()));
                          break;
                        case '호우':
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HeavyrainDetailPage()));
                          break;
                        default:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("준비 중인 페이지 입니다")),
                          );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7E5C4), // 연녹색
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          // 아이콘
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Text(
                              disaster['icon']!,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                          // 텍스트
                          Expanded(
                            child: Text(
                              disaster['title']!,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // 원형 버튼
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFF7A9476), width: 1.2),
                              color: Colors.transparent,
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7A9476)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      // 바텀 네비게이션은 기존과 동일하게 유지 가능
    );
  }

  //각 재난 별 onTap을 처리해서 상세 페이지로 이동할 수 있게 처리
  
}
