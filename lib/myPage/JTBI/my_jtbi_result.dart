
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';


void main() {
  runApp(JtbiResult2());
}

class JtbiResult2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JtbiResult(),
    );
  }
}

// document에서 원하는 값 뽑기
// Future<void> _loadUserData() async {
//   final user = Provider.of<UserModel?>(context, listen: false);
//   if (user != null && user.isSignIn) {
//     DocumentSnapshot document = await getDocumentById(user.userNo!);
//     setState(() {
//       _userDocument = document;
//       _userNickName = _userDocument.get('nickName'); // 닉네임이 없을 경우 기본값 설정
//       _userStatus = _userDocument.get('status');
//       print('닉네임: $_userNickName');
//       print('권한: $_userStatus');
//     });
//   }
// }
//
//
//
//
//
// Navigator.push(context, MaterialPageRoute(builder: (context) => ExExpactationReview(document: widget.document, ReId: "new")));
//  document: widget.document,




void setState(Null Function() param0) {
}

// 세션으로 document 값 구하기
Future<DocumentSnapshot> getDocumentById(String documentId) async {
  DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
  return document;
}



class JtbiResult extends StatefulWidget {
  JtbiResult({super.key});

  @override
  State<JtbiResult> createState() => _JtbiResultState();
}

class _JtbiResultState extends State<JtbiResult> {
late DocumentSnapshot _userDocument;
late String? _userNickName = "";


// @override
//   void initState() {
//   super.initState();
//     _loadUserData(context);
// }

Future<void> _loadUserData(BuildContext context) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
    DocumentSnapshot document = await getDocumentById(user.userNo!);
    setState(() {
      _userDocument = document;
      _userNickName = _userDocument.get('nickName');
      print('닉네임: $_userNickName');
    });
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '나의 취향분석',
          style: TextStyle(
            color: Colors.black, // 텍스트 색상 검은색
            fontSize: 18, // 글씨 크기 조정
          ),
        ),
        centerTitle: true, // 가운데 정렬
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트 사이의 간격을 조절
              children: [
                Text(
                  '선호 키워드',
                  style: TextStyle(
                    color: Colors.black, // 검은색
                    fontSize: 16, // 글씨 크기
                    fontWeight: FontWeight.bold, // 굵게
                  ),
                ),
                Text(
                  '서정적',
                  style: TextStyle(
                    color: Colors.purple, // 보라색
                    fontSize: 16, // 글씨 크기
                    fontWeight: FontWeight.bold, // 굵게
                  ),
                ),
              ],
            ),
            Divider(
              color: Colors.grey[300], // 수평선의 색상 설정
              thickness: 1, // 수평선의 두께 설정
              height: 20, // 수평선의 높이 설정
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              children: [
                Text(
                  '나의 취향분석결과',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 다른 위젯들을 추가할 수 있습니다.
              ],
            ),
            SizedBox(height: 10,),
            KeywordText(keyword: "마음"),
            TemperatureBar1(leftPercentage: 60, rightPercentage: 40),
            KeywordText(keyword: "에너지"),
            TemperatureBar2(leftPercentage: 70, rightPercentage: 30),
            KeywordText(keyword: "본성"),
            TemperatureBar3(leftPercentage: 50, rightPercentage: 50),
            KeywordText(keyword: "전술"),
            TemperatureBar4(leftPercentage: 80, rightPercentage: 20),

            Divider(
              color: Colors.grey[300], // 수평선의 색상 설정
              thickness: 1, // 수평선의 두께 설정
              height: 20, // 수평선의 높이 설정
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 가운데 정렬
              children: [
                Text(
                  '선호 작가',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyCollection()));
                  },
                  child: Text('더보기',
                    style: TextStyle(
                      color: Colors.grey, // 원하는 색상으로 변경하세요.
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),),
                ),
              ],
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                Container(
                  width: 79, // 이미지의 너비, 원하는 크기로 조절하세요
                  height: 79, // 이미지의 높이, 원하는 크기로 조절하세요
                  color: Colors.blue, // 배경 색상 설정
                  child: Center(
                    child: Icon(
                      Icons.person, // 원하는 아이콘을 설정하세요
                      size: 50, // 아이콘의 크기, 원하는 크기로 조절하세요
                      color: Colors.white, // 아이콘 색상 설정
                    ),
                  ),
                ),
                SizedBox(width: 16), // 이미지와 텍스트 사이의 간격 조절
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '작가 이름',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '전공',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 79, // 이미지의 너비, 원하는 크기로 조절하세요
                  height: 79, // 이미지의 높이, 원하는 크기로 조절하세요
                  color: Colors.blue, // 배경 색상 설정
                  child: Center(
                    child: Icon(
                      Icons.person, // 원하는 아이콘을 설정하세요
                      size: 50, // 아이콘의 크기, 원하는 크기로 조절하세요
                      color: Colors.white, // 아이콘 색상 설정
                    ),
                  ),
                ),
                SizedBox(width: 16), // 이미지와 텍스트 사이의 간격 조절
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '작가 이름',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '전공',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                      ),
                    ),
                  ],
                ),
              ],
            )


          ],
        ),
      ),

    );
  }
}

class KeywordText extends StatelessWidget {
  final String keyword;

  KeywordText({required this.keyword});

  @override
  Widget build(BuildContext context) {
    return Text(
      keyword,
      style: TextStyle(
        color: Colors.blueGrey,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


class TemperatureBar1 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;

  TemperatureBar1({required this.leftPercentage, required this.rightPercentage});

  @override
  Widget build(BuildContext context) {
    Color leftColor = Color(0xFF50A8AD); // #50A8AD 색상을 사용
    Color? rightColor = Colors.grey[300];

    double leftWidth = 260 * (leftPercentage / (leftPercentage + rightPercentage));
    double rightWidth = 260 * (rightPercentage / (leftPercentage + rightPercentage));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${leftPercentage.toInt()}%',
              style: TextStyle(color: leftColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(
              height: 10,
              width: leftWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: leftColor,
              ),
            ),
            Container(
              height: 10,
              width: rightWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: rightColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '${rightPercentage.toInt()}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('입체 전시',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('평면 전시',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }
}

class TemperatureBar2 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;

  TemperatureBar2({required this.leftPercentage, required this.rightPercentage});

  @override
  Widget build(BuildContext context) {
    Color leftColor = Color(0xFFE2A941);
    Color? rightColor = Colors.grey[300];

    double leftWidth = 260 * (leftPercentage / (leftPercentage + rightPercentage));
    double rightWidth = 260 * (rightPercentage / (leftPercentage + rightPercentage));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${leftPercentage.toInt()}%',
              style: TextStyle(color: leftColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(
              height: 10,
              width: leftWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: leftColor,
              ),
            ),
            Container(
              height: 10,
              width: rightWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: rightColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '${rightPercentage.toInt()}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('동적 전시',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('정적 전시',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }
}

class TemperatureBar3 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;

  TemperatureBar3({required this.leftPercentage, required this.rightPercentage});

  @override
  Widget build(BuildContext context) {
    Color? leftColor = Color(0xFF58AC8B);
    Color? rightColor = Colors.grey[300];

    double leftWidth = 260 * (leftPercentage / (leftPercentage + rightPercentage));
    double rightWidth = 260 * (rightPercentage / (leftPercentage + rightPercentage));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${leftPercentage.toInt()}%',
              style: TextStyle(color: leftColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(
              height: 10,
              width: leftWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: leftColor,
              ),
            ),
            Container(
              height: 10,
              width: rightWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: rightColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '${rightPercentage.toInt()}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('이성적사고형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('원칙주의형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }
}

class TemperatureBar4 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;

  TemperatureBar4({required this.leftPercentage, required this.rightPercentage});

  @override
  Widget build(BuildContext context) {
    Color? leftColor = Color(0xFFCDA1B5);
    Color? rightColor = Colors.grey[300];

    double leftWidth = 260 * (leftPercentage / (leftPercentage + rightPercentage));
    double rightWidth = 260 * (rightPercentage / (leftPercentage + rightPercentage));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${leftPercentage.toInt()}%',
              style: TextStyle(color: leftColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(
              height: 10,
              width: leftWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: leftColor,
              ),
            ),
            Container(
              height: 10,
              width: rightWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: rightColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '${rightPercentage.toInt()}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('계획형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('탐색형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }
}

class TemperatureBar5 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;

  TemperatureBar5({required this.leftPercentage, required this.rightPercentage});

  @override
  Widget build(BuildContext context) {
    Color? leftColor = Color(0xFF8B719A);
    Color? rightColor = Colors.grey[300];

    double leftWidth = 260 * (leftPercentage / (leftPercentage + rightPercentage));
    double rightWidth = 260 * (rightPercentage / (leftPercentage + rightPercentage));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${leftPercentage.toInt()}%',
              style: TextStyle(color: leftColor, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 20),
            Container(
              height: 10,
              width: leftWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: leftColor,
              ),
            ),
            Container(
              height: 10,
              width: rightWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: rightColor,
              ),
            ),
            SizedBox(width: 20),
            Text(
              '${rightPercentage.toInt()}%',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 5,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('자기주장형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('신중형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
          ],
        )
      ],
    );
  }
}
