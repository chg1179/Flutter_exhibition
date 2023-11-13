import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/artwork/ex_artwork_detail.dart';
import 'package:exhibition_project/gallery/gallery_info.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';

class MyCollection extends StatefulWidget {
  MyCollection({super.key});

  @override
  State<MyCollection> createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentSnapshot _userDocument;
  late String? _userNickName = "";

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
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('나의 컬렉션', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
            },
          ),
          bottom: TabBar(
            tabs: [
              Tab(child: Text("작품", style: TextStyle(fontSize: 16))),
              Tab(child: Text("작가", style: TextStyle(fontSize: 16))),
              Tab(child: Text("전시관", style: TextStyle(fontSize: 16))),
            ],
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 2.0), // 아래 보더 효과 설정
              ),
            ),
            labelColor: Colors.black, // 활성 탭의 글씨색 설정
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold, // 볼드 텍스트 설정
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: StreamBuilder(
                stream: _firestore
                    .collection('user')
                    .where('nickName', isEqualTo: _userNickName)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SpinKitWave( // FadingCube 모양 사용
                      color: Color(0xff464D40), // 색상 설정
                      size: 20.0, // 크기 설정
                      duration: Duration(seconds: 3), //속도 설정
                    );
                  } else {
                    return ListView.builder(
                      itemCount: userSnapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder(
                          stream: _firestore
                              .collection('user')
                              .doc(userSnapshot.data!.docs.first.id)
                              .collection('artworkLike')
                              .snapshots(),
                          builder: (context, artworkLikeSnapshot) {
                            if (!artworkLikeSnapshot.hasData) {
                              return SpinKitWave( // FadingCube 모양 사용
                                color: Color(0xff464D40), // 색상 설정
                                size: 20.0, // 크기 설정
                                duration: Duration(seconds: 3), //속도 설정
                              );
                            } else {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                                    crossAxisSpacing: 10, // 열 간의 간격
                                    mainAxisSpacing: 5.0, // 행 간의 간격
                                    childAspectRatio: 2.5/5
                                ),
                                itemCount: artworkLikeSnapshot.data!.docs.length,
                                itemBuilder: (BuildContext context, int index) {
                                  DocumentSnapshot artwork = artworkLikeSnapshot.data!.docs[index];
                                  return InkWell(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: artwork['artistId'], artDoc: artwork['artworkId'],)));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width * 0.43,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Color(0xff5d5148),// 액자 테두리 색상
                                                  width: 5, // 액자 테두리 두께
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xffb2b2b2), // 그림자 색상
                                                    blurRadius: 2, // 흐림 정도
                                                    spreadRadius: 1, // 그림자 확산 정도
                                                    offset: Offset(0, 1), // 그림자 위치 조정
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.all(6),
                                              child: Image.network(
                                                artwork['imageURL'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 15,),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, right: 5),
                                            child: Container(
                                                width: MediaQuery.of(context).size.width * 0.43,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xffcbcbcb), // 그림자 색상
                                                        blurRadius: 0.5, // 흐림 정도
                                                        spreadRadius: 1.5, // 그림자 확산 정도
                                                        offset: Offset(1, 1.5), // 그림자 위치 조정
                                                      ),
                                                    ],
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('${artwork['artTitle']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                                                      Text('${artwork['artistName']}', style: TextStyle(fontSize: 12),),
                                                      Text('${artwork['artDate']} / ${artwork['artType']}', style: TextStyle(fontSize: 11, color: Colors.grey[700]),),
                                                    ],
                                                  ),
                                                )
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
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
                      return Container(); // 리스트가 없을 때
                    }
                    return Column(
                      children: userSnapshot.data!.docs.map((userDoc) {
                        return StreamBuilder(
                          stream: _firestore
                              .collection('user')
                              .doc(userDoc.id)
                              .collection('artistLike')
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
                                return Container(); // 리스트가 없을 때
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
                      return Container(); // 리스트가 없을 때
                    }
                    return Column(
                      children: userSnapshot.data!.docs.map((userDoc) {
                        return StreamBuilder(
                          stream: _firestore
                              .collection('user')
                              .doc(userDoc.id)
                              .collection('galleryLike')
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> galleryLikeSnapshot) {
                            if (!galleryLikeSnapshot.hasData) {
                              return SpinKitWave(
                                color: Color(0xff464D40),
                                size: 20.0,
                                duration: Duration(seconds: 3),
                              );
                            } else {
                              if (galleryLikeSnapshot.data!.docs.isEmpty) {
                                return Container(); // 리스트가 없을 때
                              }
                              return Column(
                                children: galleryLikeSnapshot.data!.docs.map((gallery) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => GalleryInfo(document: gallery['galleryId'])),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 20),
                                      child: Row(
                                        children: [
                                          gallery['imageURL']==null || gallery['imageURL'] == "" ?
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(gallery['imageURL']),
                                            radius: 40,
                                          )
                                              : CircleAvatar(
                                            backgroundImage: NetworkImage(gallery['imageURL']),
                                            radius: 40,
                                          ),
                                          SizedBox(width: 30),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                gallery['galleryName'],
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                              Text(
                                                gallery['region'],
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
