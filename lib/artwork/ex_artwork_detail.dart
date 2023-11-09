import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class ExArtworkDetail extends StatefulWidget {
  final String doc;
  final String artDoc;

  const ExArtworkDetail({required this.doc, required this.artDoc});

  @override
  State<ExArtworkDetail> createState() => _ExArtworkDetailState();
}

class _ExArtworkDetailState extends State<ExArtworkDetail> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _artworkInfo;
  Map<String, dynamic>? _artistInfo;
  bool _loading = true;

  Future<void> _getArtworkData() async {
    final documentSnapshot = await _firestore.collection('artist').doc(widget.doc).collection('artist_artwork').doc(widget.artDoc).get();

    if (documentSnapshot.exists) {
      setState(() {
        _artworkInfo = documentSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> _getArtistData() async {
    final documentSnapshot = await _firestore.collection('artist').doc(widget.doc).get();

    if (documentSnapshot.exists) {
      setState(() {
        _artistInfo = documentSnapshot.data() as Map<String, dynamic>;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getArtworkData();
    _getArtistData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            icon: Icon(Icons.home, color: Colors.black),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body:
      _loading ? Center(
          child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 50.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ),
      )
      :CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          _artworkInfo?['imageURL'],
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15,top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  _artworkInfo?['artTitle'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.favorite_border)
                              )
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text("${_artworkInfo?['artType']} / ${_artworkInfo?['artDate']}"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistInfo(document: widget.doc)));
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            _artistInfo?['imageURL'] == null ?
                            CircleAvatar(
                              radius: 30, // 반지름 크기 조절
                              backgroundImage: AssetImage("assets/main/logo_green.png"),
                            )
                            : CircleAvatar(
                              radius: 30, // 반지름 크기 조절
                              backgroundImage: NetworkImage(_artistInfo?['imageURL']),
                            ),
                            SizedBox(width: 15),
                            Text(_artistInfo?['artistName'], style: TextStyle(fontSize: 16),)
                          ],
                        ),
                      )
                    ), // 버튼
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 30,
                      child: Stack(
                        children: [
                          Text(
                            "    추천 작품",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              height: 2.0, // 밑줄의 높이
                              width: 140,
                              color: Colors.black, // 밑줄의 색
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: StreamBuilder(
                          stream: _firestore
                              .collection('artist')
                              .doc(widget.doc)
                              .collection('artist_artwork')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: SpinKitWave( // FadingCube 모양 사용
                                color: Color(0xff464D40), // 색상 설정
                                size: 50.0, // 크기 설정
                                duration: Duration(seconds: 3), //속도 설정
                              ));
                            } else {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text('관련 작품이 없습니다.'),
                                );
                              }
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: ClampingScrollPhysics(),
                                child: Row(
                                  children: List.generate(snapshot.data!.docs.length, (index) {
                                    var artwork = snapshot.data?.docs[index];
                                    return Container(
                                      width: MediaQuery.of(context).size.width * 0.5, // 반 페이지만 표시
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: widget.doc, artDoc: artwork!.id)));
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 300,
                                                child: Image.network(
                                                  artwork?['imageURL'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8, bottom: 5, left: 5, right: 5),
                                                child: Text('${artwork?['artTitle']}', style: TextStyle(fontWeight: FontWeight.bold),),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                                                child: Text('${artwork?['artType']}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          },
                        )
                    )

                  ]
              ),
            ),
          ]
      ),
    );

  }
/////////////////////좋아요 파이어베이스//////////////////////////
  void _addLike(String exTitle, String addr,String exImage, DateTime likeDate,DateTime startDate,DateTime endDate) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      final endDateTimestamp = Timestamp.fromDate(endDate);
      final startDateTimestamp = Timestamp.fromDate(startDate);
      // Firestore에서 'exhibition' 컬렉션을 참조
      final exhibitionRef = FirebaseFirestore.instance.collection('exhibition');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await exhibitionRef.where('exTitle', isEqualTo: exTitle).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final exhibitionDoc = querySnapshot.docs.first;

        // 해당 전시회 문서의 like 필드를 1 증가시킴
        await exhibitionDoc.reference.update({'like': FieldValue.increment(1)}).catchError((error) {
          print('전시회 like 추가 Firestore 데이터 업데이트 중 오류 발생: $error');
        });

        // 나머지 코드 (사용자의 'like' 컬렉션에 추가)를 계속 진행
      } else {
        print('해당 전시회를 찾을 수 없습니다.');
      }

      /////////////////////// 온도 +0.1//////////////////////////////////
      // Firestore에서 사용자 문서를 참조
      final userDocRef = FirebaseFirestore.instance.collection('user').doc(user.userNo);

      // 사용자 문서의 heat 필드를 가져옴
      final userDoc = await userDocRef.get();
      final currentHeat = (userDoc.data()?['heat'] as double?) ?? 0.0;

      // 'heat' 필드를 0.1씩 증가시킴
      final newHeat = currentHeat + 0.1;

      // 'heat' 필드를 업데이트
      await userDocRef.update({'heat': newHeat});

      // user 컬렉션에 좋아요
      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('like')
          .add({
        'exTitle': exTitle,
        'addr': addr,
        'exImage': exImage,
        'likeDate': Timestamp.fromDate(likeDate),
        'startDate': startDateTimestamp,
        'endDate': endDateTimestamp,
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });

    } else {
      print('사용자가 로그인되지 않았거나 evtTitle이 비어 있습니다.');
    }
  }

  void _removeLike(String exTitle) async{
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      // Firestore에서 사용자 문서를 참조
      final userDocRef = FirebaseFirestore.instance.collection('user').doc(user.userNo);

      // 사용자 문서의 heat 필드를 가져옴
      final userDoc = await userDocRef.get();
      final currentHeat = (userDoc.data()?['heat'] as double?) ?? 0.0;

      // 'heat' 필드를 0.1씩 감소시킴
      final newHeat = currentHeat - 0.1;

      // 'heat' 필드를 업데이트
      await userDocRef.update({'heat': newHeat});


      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('like')
          .where('exTitle', isEqualTo: exTitle) // 'exTitle' 필드와 값이 일치하는 데이터 검색
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.delete(); // 검색된 모든 문서를 삭제
        });
      })
          .catchError((error) {
        print('삭제 중 오류 발생: $error');
      });
    }
  }

}
