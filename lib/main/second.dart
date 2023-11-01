import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SecondPage extends StatefulWidget {
  final List<Map<String, String>> followingData = [
    {
      'profileImage': '전시2.jpg',
      'name': '사용자1',
    },
    {
      'profileImage': '전시3.jpg',
      'name': '사용자2',
    },
    {
      'profileImage': '전시5.jpg',
      'name': '사용자3',
    },
    {
      'profileImage': '전시2.jpg',
      'name': '사용자4',
    },
    {
      'profileImage': '전시3.jpg',
      'name': '사용자5',
    },
  ];

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int selectedUserIndex = -1;

  void handleUserClick(int index) {
    setState(() {
      selectedUserIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
        .collection('user')
        .orderBy('joinDate',descending: true)
        .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('에러 발생: ${snap.error}'));
          }
          if (!snap.hasData) {
            return Center(child: Text('데이터 없음'));
          }
        return Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170, // 프로필 사진 영역의 높이 설정
                child: Container(
                  color: Color(0xff464D40),// 배경색 설정
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    //itemCount: widget.followingData.length,
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snap.data!.docs[index];
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      final isSelected = index == selectedUserIndex;

                      return InkWell(
                        onTap: () => handleUserClick(index),
                        child: Column(
                          children: [
                            SizedBox(height: 80,),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.orange : Colors.transparent,
                                  width: 3.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0,right: 8),
                                child: CircleAvatar(
                                  radius: 30, // 프로필 사진 크기
                                  backgroundImage: AssetImage('assets/main/${widget.followingData[index]['profileImage']}'),
                                ),
                              ),
                            ),
                            SizedBox(height: 4), // 프로필 사진과 이름 간의 간격 조절
                            Text(
                              '${data['nickName']}',
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: PhotoGrid(),
              ),
            ],
          ),
        );
      }
    );
  }

}
class PhotoGrid extends StatefulWidget {
  PhotoGrid({super.key});

  @override
  State<PhotoGrid> createState() => _PhotoGridExState();
}

class _PhotoGridExState extends State<PhotoGrid> {

  final List<Map<String, dynamic>> _exList = [
    {'title': '차승언 개인전 <<Your love is better than life>>', 'place' : '씨알콜렉티브/서울', 'startDate':'2023.10.26', 'lastDate' : '2023.11.29', 'posterPath' : 'ex/ex1.png'},
    {'title': '김유경: Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.10.26', 'posterPath' : 'ex/ex2.png'},
    {'title': '원본 없는 판타지', 'place' : '온수공간/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex3.png'},
    {'title': '강태구몬, 닥설랍, 진택 : The Instant kids', 'place' : '러브 컨템포러리 아트/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex4.jpg'},
    {'title': '차승언 개인전 <<Your love is better than life>>', 'place' : '씨알콜렉티브/서울', 'startDate':'2023.10.26', 'lastDate' : '2023.11.29', 'posterPath' : 'ex/ex5.jpg'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex1.png'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex2.png'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.11.15', 'lastDate' : '2023.12.15', 'posterPath' : 'ex/ex3.png'},
  ];


  String getOngoing(String lastDate, String startDate) {
    DateFormat dateFormat = DateFormat('yyyy.MM.dd'); // 입력된 'lastDate' 형식에 맞게 설정

    DateTime currentDate = DateTime.now();
    DateTime exLastDate = dateFormat.parse(lastDate); // 'lastDate'를 DateTime 객체로 변환
    DateTime exStartDate = dateFormat.parse(startDate);

    // 비교
    if(currentDate.isBefore(exStartDate)){
      return "예정";
    }else if(currentDate.isBefore(exLastDate)) {
      return "진행중";
    } else {
      return "종료";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 330, // 각 열의 최대 너비
                    crossAxisSpacing: 15.0, // 열 간의 간격
                    mainAxisSpacing: 20.0, // 행 간의 간격
                    childAspectRatio: 2/5.1
                ),
                itemCount: _exList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      print("${_exList[index]['title']} 눌럿다");
                    },
                    child: Card(
                      margin: const EdgeInsets.all(5.0),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child: Image.asset("assets/${_exList[index]['posterPath']}"),
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 17, top: 15, bottom: 5),
                              decoration: BoxDecoration(
                              ),
                              child: Text(getOngoing(_exList[index]['lastDate'],_exList[index]['startDate']),
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationStyle: TextDecorationStyle.double,
                                    decorationColor: Color(0xff464D40),
                                    decorationThickness: 1.5,
                                  )
                              )
                          ),
                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(_exList[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(_exList[index]['place'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text("${_exList[index]['startDate']} ~ ${_exList[index]['lastDate']}"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

