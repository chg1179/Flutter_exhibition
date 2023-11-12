import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../artist/artist_info.dart';
import '../../model/user_model.dart';
import 'jbti1.dart';

class JtbiResult extends StatefulWidget {
  @override
  State<JtbiResult> createState() => _JtbiResultState();
}
class _JtbiResultState extends State<JtbiResult> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late UserModel user;
  Map<String, dynamic>? _jbtiData;
  double dynamicValue = 0.0;
  double astaticValue = 0.0;
  double appreciationValue = 0.0;
  double classicValue = 0.0;
  double dimensionValue = 0.0;
  double exploratoryValue = 0.0;
  double flatValue = 0.0;
  double newValue = 0.0;
  late String? _userNickName = "";
  late DocumentSnapshot _userDocument;

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
      });
    }
  }
  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }


  @override
  void initState() {
    super.initState();
    _getJbtiData();
  }

  void _getJbtiData() async {
    try {
      user = Provider.of<UserModel>(context, listen: false);
      QuerySnapshot? snapshot = await getChildStreamData((user.userNo).toString(), 'user', 'jbti', 'dynamicValue', false).first;
      if (snapshot.docs.isNotEmpty) {
        // 첫 번째 문서의 데이터에 접근.
        _jbtiData = snapshot.docs.first.data() as Map<String, dynamic>;
        dynamicValue = (_jbtiData!['dynamicValue'] as num).toDouble();
        astaticValue = (_jbtiData!['astaticValue'] as num).toDouble();
        appreciationValue = (_jbtiData!['appreciationValue'] as num).toDouble();
        classicValue = (_jbtiData!['classicValue'] as num).toDouble();
        dimensionValue = (_jbtiData!['dimensionValue'] as num).toDouble();
        exploratoryValue = (_jbtiData!['exploratoryValue'] as num).toDouble();
        flatValue = (_jbtiData!['flatValue'] as num).toDouble();
        newValue = (_jbtiData!['newValue'] as num).toDouble();
        setState(() {}); // Rebuild를 유도하기 위해 setState 호출
      } else {
        print('취향 분석 결과가 없습니다.');
      }
    } catch (e) {
      print('데이터를 가져오는 중 오류 발생: $e');
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
          centerTitle: true,
          // 가운데 정렬
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 텍스트 사이의 간격을 조절
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 가운데 정렬
                children: [
                  Text(
                    '나의 취향분석결과',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => App()));
                    },
                    child: Text('다시하기',
                      style: TextStyle(
                        color: Colors.grey, // 원하는 색상으로 변경하세요.
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),
                  // 다른 위젯들을 추가할 수 있습니다.
                ],
              ),
              SizedBox(height: 10,),
              KeywordText(keyword: "차원"),
              if (dimensionValue != 0.0 && flatValue != 0.0)
                TemperatureBar1(
                  leftPercentage: dimensionValue > flatValue ? dimensionValue : flatValue,
                  rightPercentage: dimensionValue > flatValue ? flatValue : dimensionValue,
                  type : dimensionValue > flatValue ? 0 : 1
                ),
              KeywordText(keyword: "움직임"),
              if (astaticValue != 0.0 && dynamicValue != 0.0)
                TemperatureBar2(
                  leftPercentage: astaticValue > dynamicValue ? astaticValue : dynamicValue,
                  rightPercentage: astaticValue > dynamicValue ? dynamicValue : astaticValue,
                    type : dimensionValue > flatValue ? 0 : 1
                ),
              KeywordText(keyword: "변화"),
              if (classicValue != 0.0 && newValue != 0.0)
                TemperatureBar3(
                  leftPercentage: classicValue > newValue ? classicValue : newValue,
                  rightPercentage: classicValue > newValue ? newValue : classicValue,
                    type : dimensionValue > flatValue ? 0 : 1
                ),
              KeywordText(keyword: "경험"),
              if (appreciationValue != 0.0 && exploratoryValue != 0.0)
                TemperatureBar4(
                  leftPercentage: appreciationValue > exploratoryValue ? appreciationValue : exploratoryValue,
                  rightPercentage: appreciationValue > exploratoryValue ? exploratoryValue : appreciationValue,
                    type : dimensionValue > flatValue ? 0 : 1
                ),
              KeywordText(keyword: "자아"),
              TemperatureBar5(
                leftPercentage: (
                    (dimensionValue >= flatValue ? dimensionValue : flatValue) +
                        (dynamicValue >= astaticValue ? dynamicValue : astaticValue) +
                        (classicValue >= newValue ? classicValue : newValue) +
                        (appreciationValue >= exploratoryValue ? appreciationValue : exploratoryValue)
                ) / 4.0,
                rightPercentage: 100.0 - (
                    (dimensionValue >= flatValue ? flatValue : dimensionValue) +
                        (dynamicValue >= astaticValue ? astaticValue : dynamicValue) +
                        (classicValue >= newValue ? newValue : classicValue) +
                        (appreciationValue >= exploratoryValue ? exploratoryValue : appreciationValue)
                ) / 4.0,
                  type : dimensionValue > flatValue ? 0 : 1
              ),

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
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => MyCollection()));
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
              Padding(
                padding: const EdgeInsets.all(10),
                child: StreamBuilder(
                  stream: _firestore
                      .collection('user')
                      .where('nickName', isEqualTo: _userNickName)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return SpinKitWave(
                        color: Color(0xff464D40),
                        size: 20.0,
                        duration: Duration(seconds: 3),
                      );
                    } else {
                      if (userSnapshot.data!.docs.isEmpty) {
                        return Text('아직 선호하는 작가가 없으시네요!',style: TextStyle(color: Colors.grey),); // 리스트가 없을 때 메시지 표시
                      }
                      return Column(
                        children: userSnapshot.data!.docs.map((userDoc) {
                          return StreamBuilder(
                            stream: _firestore
                                .collection('user')
                                .doc(userDoc.id)
                                .collection('artistLike')
                                .limit(2)
                                .snapshots(),
                            builder: (context, AsyncSnapshot<QuerySnapshot> artistLikeSnapshot) {
                              if (!artistLikeSnapshot.hasData) {
                                return SpinKitWave(
                                  color: Color(0xff464D40),
                                  size: 20.0,
                                  duration: Duration(seconds: 3),
                                );
                              } else {
                                if (artistLikeSnapshot.data!.docs.isEmpty) {
                                  return Text('아직 선호하는 작가가 없으시네요!',style: TextStyle(color: Colors.grey),); // 리스트가 없을 때 메시지 표시
                                }
                                return Column(
                                  children: artistLikeSnapshot.data!.docs.map((artistDoc) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ArtistInfo(document: artistDoc['artistId'])),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                                        child: Row(
                                          children: [
                                            artistDoc['imageURL']==null || artistDoc['imageURL'] == "" ?
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(artistDoc['imageURL']),
                                              radius: 40,
                                            )
                                                : CircleAvatar(
                                              backgroundImage: NetworkImage(artistDoc['imageURL']),
                                              radius: 40,
                                            ),
                                            SizedBox(width: 30),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  artistDoc['artistName'],
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                                Text(
                                                  artistDoc['expertise'],
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
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
  final double type;
  TemperatureBar1({required this.leftPercentage, required this.rightPercentage, required this.type});
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
            Text(
              type == 0 ? '입체형' : '평면형',
              style: TextStyle(fontSize: 10, color: leftColor, fontWeight: FontWeight.bold),
            ),
            Text(
              type != 0 ? '입체형' : '평면형',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}
class TemperatureBar2 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;
  final double type;
  TemperatureBar2({required this.leftPercentage, required this.rightPercentage, required this.type});
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
            Text(
              type == 0 ? '정적형' : '동적형',
              style: TextStyle(fontSize: 10, color: Color(0xFFE2A941), fontWeight: FontWeight.bold),
            ),
            Text(
              type != 0 ? '정적형' : '동적형',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],

        )
      ],
    );
  }
}
class TemperatureBar3 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;
  final double type;
  TemperatureBar3({required this.leftPercentage, required this.rightPercentage,  required this.type});
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
            Text(
              type == 0 ? '고전적' : '현대적',
              style: TextStyle(fontSize: 10, color: leftColor, fontWeight: FontWeight.bold),
            ),
            Text(
              type != 0 ? '고전적' : '현대적',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],

        )
      ],
    );
  }
}
class TemperatureBar4 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;
  final double type;
  TemperatureBar4({required this.leftPercentage, required this.rightPercentage, required this.type});
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
            Text(
              type == 0 ? '감상형' : '탐구형',
              style: TextStyle(fontSize: 10, color: leftColor, fontWeight: FontWeight.bold),
            ),
            Text(
              type != 0 ? '감상형' : '탐구형',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],

        )
      ],
    );
  }
}
class TemperatureBar5 extends StatelessWidget {
  final double leftPercentage;
  final double rightPercentage;
  final double type;
  TemperatureBar5({required this.leftPercentage, required this.rightPercentage, required this.type});
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
            Text(
              type == 0 ? '자기주장형' : '타협형',
              style: TextStyle(fontSize: 10, color: leftColor, fontWeight: FontWeight.bold),
            ),
            Text(
              type != 0 ? '자기주장형' : '타협형',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],

        )
      ],
    );
  }
}