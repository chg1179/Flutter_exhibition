import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/exhibition/ex_list.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:provider/provider.dart';

import '../community/post_main.dart';
import '../main.dart';
import '../model/user_model.dart';

class BeBackEx extends StatefulWidget {
  BeBackEx({super.key});

  @override
  State<BeBackEx> createState() => _BeBackExState();
}

class _BeBackExState extends State<BeBackEx> {
  final _search = TextEditingController();
  late DocumentSnapshot _userDocument;

  final List<Map<String, dynamic>> _exList = [];


  String getOngoing(DateTime endDate, DateTime startDate) {
    DateFormat dateFormat = DateFormat('yyyy.MM.dd'); // 입력된 'lastDate' 형식에 맞게 설정

    DateTime currentDate = DateTime.now();
    String endDateString = dateFormat.format(endDate);
    String startDateString = dateFormat.format(startDate);

    // 비교
    if(currentDate.isBefore(startDate)){
      return "예정";
    }else if(currentDate.isBefore(endDate)) {
      return "진행중";
    } else {
      return "종료";
    }
  }

  /// 유저 - 다녀온 컬렉션 연결
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document =
    await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }
  Future<void> getEventsForUser() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(_userDocument.id)
        .collection('visit')
        .orderBy('visitDate', descending: true)
        .get();

    // Firestore에서 가져온 데이터를 사용하여 _exList를 채우는 코드 추가
    _exList.clear(); // 기존 목록을 비웁니다.
  }
  /// 다녀온 전시회 길이구하기
  Future<int> getSubcollectionLength() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.userNo)
        .collection('visit')
        .get();

    int subcollectionLength = querySnapshot.size;

    return subcollectionLength;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;
    final user = Provider.of<UserModel?>(context, listen: false);
    int _currentIndex = 0;

    void _onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _search,
          decoration: InputDecoration(
            border: InputBorder.none, // 테두리 없애는 부분
            enabledBorder: InputBorder.none, // 활성화된 상태의 테두리 없애는 부분
            hintText: "검색어를 입력하세요.",
            labelStyle: TextStyle(
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20.0),
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Color(0xff464D40)),
              onPressed: () {
                print("돋보기 눌럿다");
              },
            ),
          ),
          style: TextStyle(),
          cursorColor: Color(0xff464D40),
          onChanged: (newValue) {
            setState(() {});
          },
        ),
      ),
      body: Column(
        children: [
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 24, top: 13, bottom: 8),
              child: Text("다녀온 전시", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(
                  0xff000000)))
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(user?.userNo)
                    .collection('visit')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('에러 발생: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_satisfied_alt, // 원하는 이모지 아이콘 선택
                            size: 64, // 이모지 크기 설정
                            color: Colors.grey, // 이모지 색상 설정
                          ),
                          Text(
                            '아직 다녀온 전시가 없으시군요!',
                            style: TextStyle(
                              fontSize: 18, // 큰 글씨 폰트 크기
                              color: Colors.black, // 글자 색상 설정
                            ),
                          ),
                          Text(
                            '다녀온 전시회를 이곳에 담아 추억하세요!',
                            style: TextStyle(
                              fontSize: 11, // 작은 글씨 폰트 크기
                              color: Colors.grey, // 회색
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                          crossAxisSpacing: 10.0, // 열 간의 간격
                          mainAxisSpacing: 10.0, // 행 간의 간격
                          childAspectRatio: 2/5
                      ),
                      //itemCount: _exList.length,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        /// user-visit collection 변수 호출
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;

                        // 필드 값을 가져와 변수에 할당
                        var exTitle = data['exTitle'] ?? '';
                        var startDate = data['startDate'] as Timestamp;
                        var endDate = data['endDate'] as Timestamp;
                        var addr = data['addr'] ?? '';
                        var exImage = data['exImage'] ?? '';
                        var visitDate = data['visitDate'] as Timestamp;

                        // Timestamp를 DateTime으로 변환
                        DateTime startDateDateTime = startDate.toDate();
                        DateTime endDateDateTime = endDate.toDate();
                        DateTime visitDateTime = visitDate.toDate();

                        return InkWell(
                          onTap: (){
                            print("$exTitle 눌럿다 다되면 이동시켜라");
                            ///연결만 시키면 되는데 이거 본사람 당첨
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id) ));
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
                                  child: Image.network(exImage),
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 17, top: 15, bottom: 5),
                                    decoration: BoxDecoration(
                                    ),
                                    child: Text(getOngoing(endDateDateTime, startDateDateTime),
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
                                    child: Text(exTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(addr, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text("${DateFormat('yyyy.MM.dd').format(startDateDateTime)} ~ ${DateFormat('yyyy.MM.dd').format(endDateDateTime)}"),
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
                  );
                }
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 이 부분을 추가합니다.
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },
                icon : Icon(Icons.home),
                color: Colors.grey
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                },
                icon : Icon(Icons.account_balance, color: Colors.grey)
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                },
                icon : Icon(Icons.comment),
                color: Colors.grey
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                },
                icon : Icon(Icons.library_books),
                color: Colors.grey
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                },
                icon : Icon(Icons.account_circle),
                color: Color(0xff464D40)
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

class exVisit {
  final String exTitle;
  final DateTime visitDate;
  final String exImage;
  final String addr;
  final String docId;
  final DateTime startDate;
  final DateTime endDate;

  exVisit(this.exTitle, this.exImage, this.visitDate,
      this.addr, this.docId, this.startDate, this.endDate,);
}
