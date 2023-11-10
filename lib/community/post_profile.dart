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
  final _firestore = FirebaseFirestore.instance;
  bool isFollowed = false;
  bool _loading = true;
  List<Map<String, dynamic>>? _followInfo;
  Map<String, dynamic>? _userInfo;
  List<Map<String, String>> _imgList = [];

  ButtonStyle getFollowButtonStyle() {
    return isFollowed
        ? ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    )
        : ButtonStyle(); // 기본 스타일 반환
  }

  Future<void> toggleFollow() async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      final sessionUserId = user.userNo;
      final userSnapshot = await _firestore.collection('user').doc(user.userNo).get();
      final userDoc = userSnapshot.data() as Map<String, dynamic>;
      final sessionUserNickName = userDoc['nickName'];
      final profileImage = userDoc['profileImage'];

      try {
        final userQuerySnapshot = await _firestore.collection('user').where('nickName', isEqualTo: widget.nickName).get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          final userId = userQuerySnapshot.docs.first.id;
          final followerQuerySnapshot = await _firestore.collection('user').doc(userId).collection('follower').where('nickName', isEqualTo: sessionUserNickName).get();
          
          //상대유저프로필사진 갯또다제
          final userProfileSnapshot = await _firestore.collection('user').doc(userId).get();
          final userProfileImage = userProfileSnapshot['profileImage'];

          if (followerQuerySnapshot.docs.isEmpty) {
            // 팔로우: 세션 유저를 상대 유저의 follower 서브컬렉션에 추가
            await _firestore.collection('user').doc(userId).collection('follower').add({
              'nickName': sessionUserNickName,
              'profileImage': profileImage,
            });

            // 세션 유저의 following 서브컬렉션에 상대 유저 정보 추가
            await _firestore.collection('user').doc(sessionUserId).collection('following').add({
              'nickName': widget.nickName,
              'profileImage': userProfileImage
            });

            // UI 업데이트 및 필요한 작업 수행
            setState(() {
              isFollowed = true;
            });
          } else {
            // 언팔로우: 세션 유저를 상대 유저의 follower 서브컬렉션에서 제거
            final followerDocId = followerQuerySnapshot.docs.first.id;
            await _firestore.collection('user').doc(userId).collection('follower').doc(followerDocId).delete();

            // 세션 유저의 following 서브컬렉션에서 상대 유저 정보 제거
            final followingQuerySnapshot = await _firestore.collection('user').doc(sessionUserId).collection('following').where('nickName', isEqualTo: widget.nickName).get();
            if (followingQuerySnapshot.docs.isNotEmpty) {
              final followingDocId = followingQuerySnapshot.docs.first.id;
              await _firestore.collection('user').doc(sessionUserId).collection('following').doc(followingDocId).delete();
            }

            // UI 업데이트 및 필요한 작업 수행
            setState(() {
              isFollowed = false;
            });
          }
        }
      } catch (e) {
        print('팔로우 토글 에러: $e');
      }
    }
  }

  Future<void> _getFollowData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    try {
      final userQuerySnapshot = await _firestore.collection('user').where('nickName', isEqualTo: widget.nickName).get();
      if (userQuerySnapshot.docs.isNotEmpty) {
        final userId = userQuerySnapshot.docs.first.id;
        final userSnapshot = await _firestore.collection('user').doc(user?.userNo).get();
        final userDoc = userSnapshot.data() as Map<String, dynamic>;
        final sessionUserNickName = userDoc['nickName'];
        final followerQuerySnapshot = await _firestore.collection('user').doc(userId).collection('follower').where('nickName', isEqualTo: sessionUserNickName).get();

        // 데이터를 가져온 후 팔로우 여부 확인
        bool isCurrentlyFollowed = followerQuerySnapshot.docs.isNotEmpty;

        // isCurrentlyFollowed 값에 따라 UI 등 필요한 작업 수행
        // 최초 접근 시 팔로우 여부에 따라 UI 설정
        if (_loading) {
          setState(() {
            isFollowed = isCurrentlyFollowed;
            _loading = false;
          });
        }
        // 팔로잉 및 팔로워 수 가져오기
        final followingCount = await getFollowingCount(userId);
        final followerCount = await getFollowerCount(userId);

        // 팔로잉 및 팔로워 수를 상태에 저장
        setState(() {
          _followingCount = followingCount;
          _followerCount = followerCount;
        });
      }
    } catch (e) {
      print('팔로우 데이터 가져오기 에러: $e');
    }
  }

  int _followingCount = 0;
  int _followerCount = 0;



  Future<bool> checkIfFollowed(String userId) async {
    final user = Provider.of<UserModel?>(context, listen: false);

    if (user != null && user.isSignIn) {
      final sessionUserId = user.userNo;

      try {
        // 팔로우 여부 확인
        final querySnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(sessionUserId)
            .collection('follower')
            .where('nickName', isEqualTo: widget.nickName)
            .get();

        return querySnapshot.docs.isNotEmpty;
      } catch (e) {
        print('팔로우 여부 확인 에러: $e');
      }
    }

    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserImages(); // 초기 유저 이미지 데이터 가져오기
    _getFollowData();
  }

///////////////////////////////////////////////////////////////////////
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
  // 팔로워 수 구하기

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
                              _followerCount.toString(),
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
                              _followingCount.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "팔로잉",
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 버튼이 클릭되었을 때 수행할 동작
                            toggleFollow();
                          },
                          // 토글 버튼 스타일을 가져옴
                          style: getFollowButtonStyle(),
                          icon: Icon(isFollowed ? Icons.check : Icons.add),
                          label: Text(isFollowed ? "팔로잉" : "팔로우"),
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
