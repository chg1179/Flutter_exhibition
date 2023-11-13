import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart';

class ExExpactationReview extends StatefulWidget {
  final String document;
  final String ReId;

  const ExExpactationReview({required this.document, required this.ReId});

  @override
  State<ExExpactationReview> createState() => _ExExpactationReviewState();
}

class _ExExpactationReviewState extends State<ExExpactationReview> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _exDetailData;
  Map<String, dynamic>? _userData;
  final _review = TextEditingController();
  bool txtCheck = false;
  late DocumentSnapshot _userDocument;
  late String? _userNickName;
  Map<String, dynamic>? _expactationReviewData;

  // document에서 원하는 값 뽑기
  Future<void> _loadUserData() async {
    final user = Provider.of<UserModel?>(context, listen: false);
    if (user != null && user.isSignIn) {
      DocumentSnapshot document = await getDocumentById(user.userNo!);
      setState(() {
        _userDocument = document;
        _userNickName = _userDocument.get('nickName') ?? 'No Nickname'; // 닉네임이 없을 경우 기본값 설정
        print('닉네임: $_userNickName');
      });
    }
  }

  // 세션으로 document 값 구하기
  Future<DocumentSnapshot> getDocumentById(String documentId) async {
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('user').doc(documentId).get();
    return document;
  }

  void _getExDetailData() async {
    try {
      final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _exDetailData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print('전시회 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _getUserData() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('exhibition')
          .where('nickName', isEqualTo: _userNickName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentSnapshot = querySnapshot.docs.first;
        setState(() {
          _userData = documentSnapshot.data() as Map<String, dynamic>;
        });
        print(_userData);
      } else {
        print('유저 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }


  void _getReviewData() async {
    try {
      final documentSnapshot = await _firestore.collection('exhibition').doc(widget.document).collection('expactationReview').doc(widget.ReId).get();
      if (documentSnapshot.exists) {
        setState(() {
          _expactationReviewData = documentSnapshot.data() as Map<String, dynamic>;
          _review.text = _expactationReviewData?['content'];
        });
      } else {
        print('기대평 정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _init() async{
    setState(() {
      _review.addListener(updateButtonState);
    });
  }

  void updateButtonState() async {
    setState(() {
      txtCheck = _review.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _init();
    _getExDetailData();
    _getReviewData();
    _getUserData();
  }

  Future<void> addExpactationReview() async {
    try {
      Map<String, dynamic> reviewData = {
        'content': _review.text,
        'userNick': _userNickName,
        'cDateTime': FieldValue.serverTimestamp(),
        'uDateTime': FieldValue.serverTimestamp(),
        'userImage' : _userData?['profileImage']
      };

      // Add review data
      DocumentReference reviewReference = await _firestore.collection('exhibition').doc(widget.document).collection('expactationReview').add(reviewData);

      _review.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('기대평이 등록되었습니다.', style: TextStyle(fontSize: 16),),
            actions: <Widget>[
              TextButton(
                child: Text('확인', style: TextStyle(color: Color(0xff464D40)),),
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 한 번 더 뒤로가기해서 전시회 페이지로 돌아가기
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('기대평 등록 중 오류 발생: $e');
    }
  }

  Future<void> updateExpactationReview() async {
    try {
      Map<String, dynamic> reviewData = {
        'content': _review.text,
        'uDateTime': FieldValue.serverTimestamp(),
      };

      // Update review data
      await _firestore
          .collection('exhibition')
          .doc(widget.document)
          .collection('expactationReview')
          .doc(widget.ReId)
          .update(reviewData);

      _review.clear();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('성공적으로 수정되었습니다.', style: TextStyle(fontSize: 16),),
            actions: <Widget>[
              TextButton(
                child: Text('확인', style: TextStyle(color: Color(0xff464D40)),),
                onPressed: () {
                  Navigator.pop(context); // 다이얼로그 닫기
                  Navigator.pop(context); // 전시회 페이지로 이동
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('리뷰 업데이트 중 오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_exDetailData?['exTitle']} 기대평 작성", style: TextStyle(color: Colors.black, fontSize: 17),),
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Text("기대평 작성", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  Text(" *", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff464D40))),
                ],
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _review,
                maxLines: 4, // 입력 필드에 표시될 최대 줄 수
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffc0c0c0), // 테두리 색상 설정
                        width: 1.0, // 테두리 두께 설정
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff464D40), // 포커스된 상태의 테두리 색상 설정
                        width: 2.0,
                      ),
                    ),
                    hintText: "기대평을 작성해주세요"
                ),
              ),
              SizedBox(height: 50,),
              Row(
                children: [
                  Text("내 손안의 전시회 리뷰 정책", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Icon(Icons.chevron_right, color: Colors.grey, size: 18,)
                ],
              ),
              SizedBox(height: 5,),
              Text("전시회 이용과 무관한 내용이나 허위 및 과장, 저작물 무단 도용, 초상권 및 사생활 침해, 비방 등이 포함된 내용은 삭제될 수 있습니다.", style: TextStyle(fontSize: 13, color: Colors.grey)),
              SizedBox(height: 45,),
              Container(
                width: MediaQuery.of(context).size.width - 25,
                height: 50,
                child: ElevatedButton(
                    style: txtCheck ? ElevatedButton.styleFrom(
                      foregroundColor: Color(0xffD4D8C8),
                      backgroundColor: Color(0xff464D40),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ) : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                    onPressed: (){
                      if (txtCheck) {
                        if (widget.ReId == "new") {
                          addExpactationReview();
                        } else {
                          updateExpactationReview();
                        }
                      } else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('기대평 내용을 작성해주세요.', style: TextStyle(fontSize: 16)),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('확인', style: TextStyle(color: Color(0xff464D40))),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(widget.ReId=="new" ? "기대평 등록" : "기대평 수정", style: TextStyle(fontSize: 18),)
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }
}
