import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:exhibition_project/review/review_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';

class MyPageAddView2 extends StatefulWidget {
  @override
  State<MyPageAddView2> createState() => _MyPageAddView2State();
}

class _MyPageAddView2State extends State<MyPageAddView2>
  with SingleTickerProviderStateMixin {
  late DocumentSnapshot _userDocument;
  String? _userNickName = "";

  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname';
      });
    }
  }

  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document =
    await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  Future<List<DocumentSnapshot>> _getReviews() async {
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('review')
        .where('userNickName', isEqualTo: _userNickName)
        .get();

    return reviewSnapshot.docs;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('나의 후기글', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyPage(),
              ),
            );
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        future: _getReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: SpinKitWave( // FadingCube 모양 사용
              color: Color(0xff464D40), // 색상 설정
              size: 30.0, // 크기 설정
              duration: Duration(seconds: 3), //속도 설정
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> reviews = snapshot.data as List<DocumentSnapshot>;
            if (reviews.isEmpty) {
              return Container(
                child: Center(
                  child: Text("작성한 후기글이 없습니다."),
                ),
              );
            }
            return ListView(
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          String imageURL = reviews[index].get('imageURL');
                          return InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetail(document: reviews[index].id)));
                              },
                              child: Image.network(imageURL, fit: BoxFit.cover)
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

