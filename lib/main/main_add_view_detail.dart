import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddViewDetail extends StatefulWidget {
  final String title;
  final String subtitle;

  AddViewDetail({required this.title, required this.subtitle});

  @override
  State<AddViewDetail> createState() => _AddViewDetailState();
}

class _AddViewDetailState extends State<AddViewDetail> {
  final List<Map<String, String>> exhibitionData = [
    {
      'exTitle': 'exTitle',
      'galleryName': '(FK)galleryName',
      'addr': '(FK)address+detailsAddress',
      'Date': 'startDate ~ endDate',
      'exContents': '(FK)exContents',
      'exImage': '전시이미지란'
    },
  ];
  int selectedUserIndex = -1;
  String firstWord = ''; // 띄어쓰기 전의 글자를 저장할 변수 추가

  void handleUserClick(int index) {
    setState(() {
      selectedUserIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    int spaceIndex = widget.title.indexOf(' ');
    if (spaceIndex != -1) {
      firstWord = widget.title.substring(0, spaceIndex);
    } else {
      firstWord = widget.title; // 띄어쓰기가 없을 경우 전체 문자열 저장
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('exhibition')
            .where('type', isEqualTo: firstWord)
            //.orderBy('startDate', descending: true)
            .limit(6)
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

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black, // 화살표 아이콘의 색상을 검은색으로 설정
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text("어떤 전시회가 좋을지 고민된다면?🤔", style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
              backgroundColor: Colors.white,
              elevation: 0, // 그림자를 제거합니다.
            ),

            ///////////////////////////////앱바끝////////////////////////////

            body: Column(
              children: [
                SizedBox(height: 16),
                Center(child: Text(widget.title, style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold))),
                SizedBox(height: 16),
                Center(child: Text(widget.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey))),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical, // 세로 스크롤
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snap.data!.docs[index];
                        Map<String, dynamic> data = doc.data() as Map<
                            String,
                            dynamic>;
                        final isSelected = index == selectedUserIndex;
                        final galleryNo = data['galleryNo'] as String;
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('gallery').doc(galleryNo).snapshots(),
                          builder: (context, gallerySnapshot) {
                            if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if(gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                              final addr = gallerySnapshot.data!['addr'] as String;
                              final galleryRegion = gallerySnapshot.data!['region'] as String;
                              return InkWell( // 클릭시 이벤트 주는 명령어
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: doc.id))),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            Center(
                                              child: Image.network(
                                                '${data['imageURL']}',
                                                fit: BoxFit.cover,
                                                // 이미지를 가능한 최대 크기로 채우도록 설정합니다.
                                                width: 200,
                                                // 원하는 너비를 설정합니다.
                                                height: 200, // 원하는 높이를 설정합니다.
                                              ),
                                            ),
                                            Center(child: Text(
                                              '${data['exTitle']}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),)),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                    '장소 : ${data['galleryName']} / ${data['region']}',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                Text('주소 : $addr',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                                Text(
                                                    '기간 : ${formatFirestoreDate(
                                                        data['startDate'])} ~ ${formatFirestoreDate(
                                                        data['endDate'])}',
                                                    style: TextStyle(
                                                        fontSize: 12)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Center(
                                            child: Text(data['content'] != null && data['content'] != '' ? data['content'] : '현재 준비중 입니다.')
                                        ),
                                        Divider(
                                          color: Colors.grey, // 수평선의 색상 설정
                                          thickness: 1, // 수평선의 두께 설정
                                          height: 20, // 수평선의 높이 설정
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Text('갤러리 데이터가 없습니다.');
                            }
                          }
                        );
                      }
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  ///주소에서 지역만 뽑는 함수
  String getAddressPart(String? addr) {
    if (addr != null) {
      int spaceIndex = addr.indexOf(' ');
      if (spaceIndex != -1) {
        String addressPart = addr.substring(0, spaceIndex);
        return addressPart;
      }
    }
    return '주소 정보 없음';
  }

  ///년월일 포멧 함수
  String formatFirestoreDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
}