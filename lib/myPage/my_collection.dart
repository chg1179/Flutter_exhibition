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
              child: SingleChildScrollView(
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '다시 로그인 해주세요.',
                              style: TextStyle(
                                color: Colors.grey, // 회색 글씨
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Icon(
                              Icons.sentiment_satisfied_alt, // 스마일 아이콘
                              color: Colors.grey,
                              size: 40,
                            ),
                          ],
                        );
                      }
                      return Column(
                        children: userSnapshot.data!.docs.map((userDoc) {
                          return StreamBuilder(
                            stream: _firestore
                                .collection('user')
                                .doc(userDoc.id)
                                .collection('artworkLike')
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
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 100),
                                      Text(
                                        '아직 선호하는 작품이 없으시군요!',
                                        style: TextStyle(
                                          color: Colors.grey, // 회색 글씨
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Icon(
                                        Icons.sentiment_satisfied_alt, // 스마일 아이콘
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                Container(
                                                  constraints: BoxConstraints(
                                                    maxWidth: 200, // 최대 가로 길이 설정
                                                  ),
                                                  child: Text(
                                                    artistDoc['artTitle'],
                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1, // 한 줄만 표시
                                                  ),
                                                ),
                                                Text(
                                                  artistDoc['artType'],
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  artistDoc['artistName'],
                                                  style: TextStyle(fontSize: 13),
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
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '다시 로그인 해주세요.',
                              style: TextStyle(
                                color: Colors.grey, // 회색 글씨
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Icon(
                              Icons.sentiment_satisfied_alt, // 스마일 아이콘
                              color: Colors.grey,
                              size: 40,
                            ),
                          ],
                        );
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
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 100),
                                      Text(
                                        '아직 선호하는 작가가 없으시군요!',
                                        style: TextStyle(
                                          color: Colors.grey, // 회색 글씨
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Icon(
                                        Icons.sentiment_satisfied_alt, // 스마일 아이콘
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ],
                                  );
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
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
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '다시 시도해 주세요.',
                              style: TextStyle(
                                color: Colors.grey, // 회색 글씨
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Icon(
                              Icons.sentiment_satisfied_alt, // 스마일 아이콘
                              color: Colors.grey,
                              size: 40,
                            ),
                          ],
                        );
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
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 100,),
                                      Text(
                                        '아직 선호하는 갤러리가 없으시군요!',
                                        style: TextStyle(
                                          color: Colors.grey, // 회색 글씨
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Icon(
                                        Icons.sentiment_satisfied_alt, // 스마일 아이콘
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    ],
                                  );
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
            ),
          ],
        ),
      ),
    );
  }
}
