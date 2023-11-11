import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/myPage/my_collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart';


void main() {
  runApp(MyPageAddView());
}

class MyPageAddView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPageAddView2(),
    );
  }
}


class MyPageAddView2 extends StatefulWidget {

  @override
  State<MyPageAddView2> createState() => _MyPageAddView2State();
}

class _MyPageAddView2State extends State<MyPageAddView2> with SingleTickerProviderStateMixin {
  double temperature = 36.5;
  late TabController _tabController;
  final PageController _pageController = PageController();
  late DocumentSnapshot _userDocument;
  late String? _userNickName;

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

  // Firebase에서 review 컬렉션에서 데이터 가져오기
  Future<List<DocumentSnapshot>> _getReviews() async {
    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('review')
        .where('userNickName', isEqualTo: _userNickName) // 필드명 수정 필요
        .get();

    return reviewSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (BuildContext scaffoldContext) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text('내가 쓴 후기글', style: TextStyle(color: Colors.black),),
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
                body: FutureBuilder(
                  future: _getReviews(), // review 컬렉션에서 데이터 가져오기
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 데이터 로딩 중에는 로딩 인디케이터 표시
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<DocumentSnapshot> reviews = snapshot.data as List<DocumentSnapshot>;
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
                                    // reviews에서 필요한 데이터를 가져와서 출력
                                    String imageURL = reviews[index].get('imageURL'); // 필드명 수정 필요
                                    return Image.network(imageURL, fit: BoxFit.cover,);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                )
            );
          },
        )
      )
      );
  }
}
