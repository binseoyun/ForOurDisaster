import 'package:flutter/material.dart';
import 'package:formydisaster/screens/disaster_details/earthquake_detail.dart';
import 'package:formydisaster/screens/disaster_details/flooded_detail.dart';
import 'package:formydisaster/screens/disaster_details/snow_detail.dart';
//각 disaster_detail.dart이 폴더내용을 import 해서 onTap 연결
import 'disaster_details/drought_details.dart'; //가뭄 연결
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
      backgroundColor: Colors.white, //전체 배경이 흰색이 되게
      appBar: AppBar( //상단에 표시되는 앱 바
        title: const Text('자연 재해 행동 요령'), //제목 가운데 정렬, 배경은 흰색, 글자 색은 검정색
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 검색창의 크기를 줄아려면 TextField를 Align+SizedBox 조합으로 감싸주면 됨
           Align(
  alignment: Alignment.center,
  child: SizedBox(
    width: 300, // 원하는 너비로 설정 (예: 300px)
    child: TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Search disaster',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  ),
),





            const SizedBox(height: 16),
            // 📜 리스트 (스크롤 가능)
            Expanded(
              child: ListView.builder( 
                itemCount: filteredDisasters.length,
                itemBuilder: (context, index) {
                  final disaster = filteredDisasters[index];

                  //Container를 GestureDetecotr로 감싸고, onTap에서 disaster['title'] 값을 기준으로 분기해서 각 상세 페이지로 이동하도록 구현
                  return GestureDetector(
                    onTap: (){
                      switch(disaster['title']){
                        
                       
                          case '대설':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const SnowDetailPage()),
                          );
                          break;

                          case '산사태':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const WindDetailPage()),
                          );
                          break;

                          case '지진':
                         Navigator.push(
                          context, 
                          MaterialPageRoute(builder:(context)=>const EarthquakeDetailPage()),
                          );
                          break;

                          case '침수':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const FloodedDetailPage()),
                          );
                          break;

                          case '태풍':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const WindDetailPage()),
                          );
                          break;

                          case '폭염':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const WindDetailPage()),
                          );
                          break;
                        
                      
                          case '호우':
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder:(context)=>const WindDetailPage()),
                          );
                          break;
                        
                         
                         default:
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content:Text("준비 중인 페이지 입니다"))
                         );
                      }
                    },

                
                  child:  Container( //Container내부에 재난 항목이 하나의 카드처럼 구성된 형태
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6EAD5), // 연녹색
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(disaster['icon']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(disaster['title']!, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios),
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
