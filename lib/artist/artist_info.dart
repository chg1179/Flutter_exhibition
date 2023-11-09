import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../artwork/ex_artwork_detail.dart';
import '../model/user_model.dart';

class ArtistInfo extends StatefulWidget {
  final String document;
  ArtistInfo({required this.document});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late TabController _tabController;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _artistData;
  List<Map<String, dynamic>>? _artistEducationData;
  List<Map<String, dynamic>>? _artistHistoryData;
  List<Map<String, dynamic>>? _artistAwardData;
  bool _isLoading = true;


  void _getArtistData() async {
    try {
      final documentSnapshot = await _firestore.collection('artist').doc(widget.document).get();
      if (documentSnapshot.exists) {
        final artistName = documentSnapshot.data()?['artistName']; // 가져온 데이터에서 exTitle 추출
        setState(() {
          _artistData = documentSnapshot.data() as Map<String, dynamic>;
        });
        checkIfLiked(artistName);
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _getEducationData() async {
    try {
      final querySnapshot = await _firestore
          .collection('artist')
          .doc(widget.document)
          .collection('artist_education')
          .orderBy('year')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> educationList = [];
        querySnapshot.docs.forEach((document) {
          educationList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistEducationData = educationList;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }


  void _getHistoryData() async {
    try {
      final querySnapshot = await _firestore.collection('artist').doc(widget.document).collection('artist_history').orderBy('year').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> historyList = [];
        querySnapshot.docs.forEach((document) {
          historyList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistHistoryData = historyList;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _getAwardsData() async {
    try {
      final querySnapshot = await _firestore.collection('artist').doc(widget.document).collection('artist_awards').orderBy('year').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> awardsList = [];
        querySnapshot.docs.forEach((document) {
          awardsList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistAwardData = awardsList;
          _isLoading = false;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
        _isLoading = false;
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }

  //좋아요 상태 체크
  Future<void> checkIfLiked(String artistName) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      if (artistName != null && artistName.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.userNo)
            .collection('artistLike')
            .where('artistName', isEqualTo: artistName)
            .get();

        final liked = querySnapshot.docs.isNotEmpty;
        setState(() {
          isLiked = liked;
        });
      }
    }
  }


  Widget buildSection(String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text("",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getArtistData();
    _getEducationData();
    _getHistoryData();
    _getAwardsData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalHeight = appBarHeight + statusBarHeight;
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
      PreferredSize(
        preferredSize: Size.fromHeight(250.0),
        child:
        _isLoading
            ? SizedBox()
            :AppBar(
          elevation: 0,
          flexibleSpace: Stack(
            children: [
              _artistData?['imageURL'] == null
              ?Image.asset("assets/main/logo_green.png")
              :Image.asset("assets/main/logo_green.png", width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.width, fit: BoxFit.cover),
              // :Image.network(
              //   _artistData?['imageURL'],
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.width,
              //   fit: BoxFit.cover,),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 0.2, // 테두리의 두께 조절
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15.0, top: 16, bottom: 5),
                            child: Text(
                              _artistData?['artistName'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  isLiked = !isLiked; // 좋아요 버튼 상태를 토글
                                  if (isLiked) {
                                    // 좋아요 버튼을 누른 경우
                                    // 빨간 하트 아이콘로 변경하고 추가 작업 수행
                                    _addLike(
                                      _artistData?['artistName'],
                                      _artistData?['artistEnglishName'],
                                      _artistData?['artistIntroduce'],
                                      _artistData?['artistNationality'],
                                      DateTime.now(),
                                      _artistData?['expertise'],
                                      _artistData?['imageURL'],
                                    );

                                    print('좋아요목록에 추가되었습니다');
                                  } else {
                                    _removeLike(_artistData?['artistName']);
                                    print('${_artistData?['artistName']}가 좋아요목록에서 삭제되었습니다');
                                  }
                                });
                              },
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border, // 토글 상태에 따라 아이콘 변경
                                color: isLiked ? Colors.red : null, // 빨간 하트 아이콘의 색상 변경
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 17),
                        child: Text(
                          _artistData?['expertise'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body:
      _isLoading
          ? Center(child: SpinKitWave( // FadingCube 모양 사용
        color: Color(0xff464D40), // 색상 설정
        size: 50.0, // 크기 설정
        duration: Duration(seconds: 3), //속도 설정
      ))
          : CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _artistEducationData == null ? SizedBox()
                        : Container(
                          color: Colors.white,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                padding: EdgeInsets.only(left: 15, top: 20),
                                child: Text("학력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 15),
                                width: 300,
                                height: _artistEducationData!.length * 40.toDouble(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _artistEducationData!.map((data) {
                                    return Container(
                                      padding: EdgeInsets.all(2),
                                      child: Text("${data['year']} ${data['content']}"),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                    _artistHistoryData == null ? SizedBox()
                        : Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text("이력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            width: 300,
                            height: _artistHistoryData!.length * 40.toDouble(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _artistHistoryData!.map((data) {
                                return Container(
                                  padding: EdgeInsets.all(2),
                                  child: Text("${data['year']}  ${data['content']}"),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _artistAwardData == null ? SizedBox()
                        : Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text("이력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            width: 300,
                            height: _artistAwardData!.length * 40.toDouble(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _artistAwardData!.map((data) {
                                return Container(
                                  padding: EdgeInsets.all(2),
                                  child: Text("${data['year']}  ${data['content']}"),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Text(
                            '작품',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '전시회',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: Colors.black),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - (totalHeight + 250),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SingleChildScrollView(
                            child:  Container(
                                width: MediaQuery.of(context).size.width,
                                height: 500,
                                child: StreamBuilder(
                                  stream: _firestore
                                      .collection('artist')
                                      .doc(widget.document)
                                      .collection('artist_artwork')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: SpinKitWave( // FadingCube 모양 사용
                                        color: Color(0xff464D40), // 색상 설정
                                        size: 50.0, // 크기 설정
                                        duration: Duration(seconds: 3), //속도 설정
                                      ),);
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
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: widget.document, artDoc: artwork!.id)));
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 400,
                                                        child: Image.network(
                                                          artwork?['imageURL'],
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 8, bottom: 5, left: 5, right: 5),
                                                        child: Text('${artwork?['artTitle']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                                                        child: Text('${artwork?['artType']}', style: TextStyle(color: Colors.grey[600], fontSize: 13),),
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
                            ),
                          ),
                          SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width - 40,
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('exhibition')
                                      .where('artistNo', isEqualTo: widget.document)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return SpinKitWave( // FadingCube 모양 사용
                                        color: Color(0xff464D40), // 색상 설정
                                        size: 50.0, // 크기 설정
                                        duration: Duration(seconds: 3), //속도 설정
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                        List<DocumentSnapshot> documents = snapshot.data!.docs;
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                                              crossAxisSpacing: 10.0, // 열 간의 간격
                                              mainAxisSpacing: 10.0, // 행 간의 간격
                                              childAspectRatio: 2/5
                                          ),
                                          itemCount: documents.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: (){
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ExhibitionDetail(document: documents[index].id)));
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
                                                      child: Image.network(documents[index]['imageURL']),
                                                    ),
                                                    ListTile(
                                                      title: Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 5, bottom: 5),
                                                          child: Text(documents[index]['exTitle'], style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16),
                                                              maxLines: 3,
                                                              overflow: TextOverflow.ellipsis)
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                bottom: 5),
                                                            child: Text("${documents[index]['galleryName']} / ${documents[index]['region']}", style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12),),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                bottom: 5),
                                                            child: Text(
                                                                "${DateFormat('yyyy.MM.dd').format(documents[index]['startDate'].toDate())} ~ ${DateFormat('yyyy.MM.dd').format(documents[index]['endDate'].toDate())}"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return Center(child: Text('관련 전시회가 없습니다.'));
                                      }
                                    }
                                  },
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            ),
          )
        ]
      )
    );
  }
  /////////////////////좋아요 파이어베이스//////////////////////////
  void _addLike(
      String artistName,
      String artistEnglishName,
      String artistIntroduce,
      String artistNationality,
      DateTime likeDate,
      String expertise,
      String imageURL) async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {

      ////////////////작가 컬렉션의 like/////////////////
      // Firestore에서 'artwork' 컬렉션을 참조
      final artistRef = FirebaseFirestore.instance.collection('artist');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await artistRef.where('artistName', isEqualTo: artistName).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final artistDoc = querySnapshot.docs.first;

        // 해당 전시회 문서의 like 필드를 1 증가시킴
        await artistDoc.reference.update({'like': FieldValue.increment(1)}).catchError((error) {
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
          .collection('artistLike')
          .add({
        'artistName': artistName,
        'artistEnglishName': artistEnglishName,
        'artistIntroduce': artistIntroduce,
        'artistNationality': artistNationality,
        'likeDate': Timestamp.fromDate(likeDate),
        'expertise': expertise,
        'imageURL': imageURL,
      })
          .catchError((error) {
        print('Firestore 데이터 추가 중 오류 발생: $error');
      });

    } else {
      print('사용자가 로그인되지 않았거나 artistName이 비어 있습니다.');
    }
  }

  void _removeLike(String artistName) async{
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


      //////////전시회 like-1 // Firestore에서 'exhibition' 컬렉션을 참조///////////
      // Firestore에서 'exhibition' 컬렉션을 참조
      final artistRef = FirebaseFirestore.instance.collection('artist');

      // 'exTitle'과 일치하는 문서를 쿼리로 찾음
      final querySnapshot = await artistRef.where('artistName', isEqualTo: artistName).get();

      // 'exTitle'과 일치하는 문서가 존재하는지 확인
      if (querySnapshot.docs.isNotEmpty) {
        // 첫 번째 문서를 가져오거나 원하는 방법으로 선택
        final artistDoc = querySnapshot.docs.first;

        // 현재 'like' 필드의 값을 가져옴
        final currentLikeCount = (artistDoc.data()?['like'] as int?) ?? 0;

        // 'like' 필드를 현재 값에서 -1로 감소시킴
        final newLikeCount = currentLikeCount - 1;

        // 'like' 필드를 업데이트
        await artistDoc.reference.update({'like': newLikeCount}).catchError((error) {
          print('전시회 like 삭제 Firestore 데이터 업데이트 중 오류 발생: $error');
        });

        // 나머지 코드 (사용자의 'like' 컬렉션에서 제거)를 계속 진행
      } else {
        print('해당 작가를 찾을 수 없습니다.');
      }


      FirebaseFirestore.instance
          .collection('user')
          .doc(user.userNo)
          .collection('artistLike')
          .where('artistName', isEqualTo: artistName) // 'exTitle' 필드와 값이 일치하는 데이터 검색
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
