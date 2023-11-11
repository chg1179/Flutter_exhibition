import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/user_model.dart';

class JtbiResult extends StatefulWidget {
  @override
  State<JtbiResult> createState() => _JtbiResultState();
}
class _JtbiResultState extends State<JtbiResult> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _jbtiData;
  double _dimension = 0.0;
  double _flat = 0.0;


  @override
  void initState() {
    super.initState();
    _getJbtiData();
  }

  void _getJbtiData() async {
    try {
      final querySnapshot = await _firestore
          .collection('user')
          // .doc(user?.userNo)
          // .collection('jbti')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs[0];

        if (documentSnapshot.exists) {
          setState(() {
            _jbtiData = documentSnapshot.data() as Map<String, dynamic>?;

            if (_jbtiData != null) {
              _flat = _jbtiData?['flat']?.toDouble() ?? 0.0;
              _dimension = _jbtiData?['dimension']?.toDouble() ?? 0.0;

              print('_flat: ============>>>>>>>>>=====>>>>> $_flat');
              print('_dimension:  ============>>>>>>>>>=====>>>>> $_dimension');
            }
          });
        } else {
          print('JBTI 문서가 존재하지 않습니다.');
        }
      } else {
        print('JBTI 컬렉션이 비어 있습니다.');
      }
    } catch (e) {
      print('데이터를 가져오는 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context); // 세션. UserModel
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
      body: SingleChildScrollView(
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
            KeywordText(keyword: "차원"),
            TemperatureBar1(
                leftPercentage: 60,
                rightPercentage: 40
            ),
            // TemperatureBar1(
            //   leftPercentage: _dimension ?? 0.0,
            //   rightPercentage: _flat ?? 0.0
            // ),
            KeywordText(keyword: "움직임"),
            // TemperatureBar2(
            //   leftPercentage: (_jbtiData?['dynamic'] ?? 0) >= (_jbtiData?['astatic'] ?? 0)
            //       ? (_jbtiData?['dynamic'] ?? 0)
            //       : (_jbtiData?['astatic'] ?? 0),
            //   rightPercentage: (_jbtiData?['dynamic'] ?? 0) >= (_jbtiData?['astatic'] ?? 0)
            //       ? (_jbtiData?['astatic'] ?? 0)
            //       : (_jbtiData?['dynamic'] ?? 0),
            // ),
            // KeywordText(keyword: "변화"),
            // TemperatureBar3(
            //   leftPercentage: (_jbtiData?['classic'] ?? 0) >= (_jbtiData?['new'] ?? 0)
            //       ? (_jbtiData?['classic'] ?? 0)
            //       : (_jbtiData?['new'] ?? 0),
            //   rightPercentage: (_jbtiData?['classic'] ?? 0) >= (_jbtiData?['new'] ?? 0)
            //       ? (_jbtiData?['new'] ?? 0)
            //       : (_jbtiData?['classic'] ?? 0),
            // ),
            // KeywordText(keyword: "경험"),
            // TemperatureBar4(
            //   leftPercentage: (_jbtiData?['appreciation'] ?? 0) >= (_jbtiData?['exploratory'] ?? 0)
            //       ? (_jbtiData?['appreciation'] ?? 0)
            //       : (_jbtiData?['exploratory'] ?? 0),
            //   rightPercentage: (_jbtiData?['appreciation'] ?? 0) >= (_jbtiData?['exploratory'] ?? 0)
            //       ? (_jbtiData?['exploratory'] ?? 0)
            //       : (_jbtiData?['appreciation'] ?? 0),
            // ),
            // KeywordText(keyword: "자아"),
            // TemperatureBar5(
            //   leftPercentage: (
            //       ((_jbtiData?['dimension'] ?? 0) >= (_jbtiData?['flat'] ?? 0) ? (_jbtiData?['dimension'] ?? 0) : (_jbtiData?['flat'] ?? 0)) +
            //           ((_jbtiData?['dynamic'] ?? 0) >= (_jbtiData?['astatic'] ?? 0) ? (_jbtiData?['dynamic'] ?? 0) : (_jbtiData?['astatic'] ?? 0)) +
            //           ((_jbtiData?['classic'] ?? 0) >= (_jbtiData?['new'] ?? 0) ? (_jbtiData?['classic'] ?? 0) : (_jbtiData?['new'] ?? 0)) +
            //           ((_jbtiData?['appreciation'] ?? 0) >= (_jbtiData?['exploratory'] ?? 0) ? (_jbtiData?['appreciation'] ?? 0) : (_jbtiData?['exploratory'] ?? 0))
            //   ) / 4.0,
            //   rightPercentage: 100.0 - (
            //       ((_jbtiData?['dimension'] ?? 0) >= (_jbtiData?['flat'] ?? 0) ? (_jbtiData?['flat'] ?? 0) : (_jbtiData?['dimension'] ?? 0)) +
            //           ((_jbtiData?['dynamic'] ?? 0) >= (_jbtiData?['astatic'] ?? 0) ? (_jbtiData?['astatic'] ?? 0) : (_jbtiData?['dynamic'] ?? 0)) +
            //           ((_jbtiData?['classic'] ?? 0) >= (_jbtiData?['new'] ?? 0) ? (_jbtiData?['new'] ?? 0) : (_jbtiData?['classic'] ?? 0)) +
            //           ((_jbtiData?['appreciation'] ?? 0) >= (_jbtiData?['exploratory'] ?? 0) ? (_jbtiData?['exploratory'] ?? 0) : (_jbtiData?['appreciation'] ?? 0))
            //   ) / 4.0,
            // ),
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
            Text('외향형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('내향형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
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
            Text('직관형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
            Text('현실주의형',style: TextStyle(fontSize: 10,color: Colors.grey, fontWeight: FontWeight.bold),),
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