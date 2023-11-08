import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';

class CommProfile extends StatefulWidget {
  final String nickName;

  CommProfile({required this.nickName});

  @override
  _CommProfileState createState() => _CommProfileState();
}

class _CommProfileState extends State<CommProfile> {

  List<Map<String, String>> _imgList = [];



  //이미지 리스트 불러오기
  Future<void> _fetchUserImages() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('nickName', isEqualTo: widget.nickName)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userRef = userSnapshot.docs[0].reference;

      // 1. 유저 정보 가져오기
      final userDoc = userSnapshot.docs[0].data() as Map<String, dynamic>;
      final userNickName = userDoc['nickName'];

      // 2. 해당 유저의 review 컬렉션에서 이미지 가져오기
      final imagesSnapshot = await FirebaseFirestore.instance
          .collection('review')
          .where('userNickName', isEqualTo: userNickName)
          .get();

      print('Images Snapshot Size: ${imagesSnapshot.size}');

      // 3. _imgList 업데이트
      setState(() {
        _imgList = imagesSnapshot.docs.map((doc) {
          final imageURL = doc['imageURL'] as String;
          print('Image URL: $imageURL'); // 이미지 URL 콘솔 출력
          return {
            'image': imageURL,
          };
        }).toList();
      });
    }
  }




  // 팔로잉 수 구하기
  Future<int> getFollowingCount(String desiredNickName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('nickName', isEqualTo: widget.nickName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userRef = snapshot.docs[0].reference;
      final followingSnapshot = await userRef.collection('following').get();
      return followingSnapshot.size;
    }

    return 0; // 유저를 찾지 못한 경우 0을 반환합니다.
  }

  // 팔로워 수 구하기
  Future<int> getFollowerCount(String desiredNickName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('nickName', isEqualTo: widget.nickName)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userRef = snapshot.docs[0].reference;
      final followerSnapshot = await userRef.collection('follower').get();
      return followerSnapshot.size;
    }

    return 0; // 유저를 찾지 못한 경우 0을 반환합니다.
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('user')
          .where('nickName', isEqualTo: widget.nickName) // desiredNickName에 찾고자 하는 닉네임을 넣어주세요
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            // 데이터가 존재하는 경우
            final users = snapshot.data?.docs;
            for (var user in users!) {
              // 닉네임이 같은 유저를 찾음
              final userDoc = user.data() as Map<String, dynamic>;
              final userNickName = userDoc['nickName'] ?? 'No Nickname';
              print('유저를 찾았습니다! 닉네임 : $userNickName');
            }
          } else {
            // 데이터가 없는 경우
            print('해당유저는 없는 닉네임의 유저입니다.');
          }
        } else if (snapshot.hasError) {
          // 에러 발생
          print('Error: 해당 유저는 없는 유저입니다.${snapshot.error}');
        }
        return MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text(
                "프로필",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    // 물음표 아이콘 클릭 시 수행할 동작
                  },
                  icon: Icon(Icons.search_outlined, size: 35),
                ),
                IconButton(
                  onPressed: () {
                    // 프로필 아이콘 클릭 시 수행할 동작
                  },
                  icon: Icon(Icons.account_circle, size: 35),
                ),
              ],
            ),
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nickName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '유저아이디',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ' ',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/comm_profile/5su.jpg'),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              "1",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "게시물",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text(
                              '팔로워수나타냄',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "팔로워",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text(
                              "0",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "팔로우",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            // 버튼이 클릭되었을 때 수행할 동작
                          },
                          child: Text("팔로우"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _imgList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          child: Image.network(
                            _imgList[index]['image']!,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
