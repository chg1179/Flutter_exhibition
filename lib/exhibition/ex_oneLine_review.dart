import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../firebase_storage/img_upload.dart';

class ExOneLineReview extends StatefulWidget {
  final String document;

  const ExOneLineReview({required this.document});

  @override
  State<ExOneLineReview> createState() => _ExOneLineReviewState();
}

class _ExOneLineReviewState extends State<ExOneLineReview> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _exDetailData;
  final _review = TextEditingController();
  String _observationTime = "1시간";
  String _docentOr = "없음";
  List<String> selectedTags = [];
  List<String> allTags = ["📚 유익한", "‍😆️ 즐거운", "🏔 웅장한", "😎 멋진", "👑 럭셔리한", "✨ 아름다운", "📸 사진찍기 좋은", "🌍 대규모", "🌱 소규모", "💡 독특한", "🌟 트렌디한", "👧 어린이를 위한", "👨‍🦳 어른을 위한", "🤸‍♂️ 동적인", "👀 정적인"];
  int _selectedValue = 0; // 0이면 없음, 1이면 있음
  final ImageSelector selector = ImageSelector();//이미지
  XFile? _imageFile;
  String? imgPath;
  String? imageURL;
  late ImageUploader uploader;
  bool txtCheck = false;

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
    _init();
    uploader = ImageUploader('ex_onelineReview_image');
    _getExDetailData();
  }

  Future<void> getImage() async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        imgPath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  // 이미지 추가
  Future<void> uploadImage() async {
    if (_imageFile != null) {
      imageURL = await uploader.uploadImage(_imageFile!);
      print('Uploaded to Firebase Storage: $imageURL');
    } else {
      print('No image selected.');
    }
  }

  Widget _buildImageWidget() {
    if (imgPath != null) {
      if (kIsWeb) {
        // 웹 플랫폼에서는 Image.network 사용
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5), // 원하는 라디우스 값 적용
              child: Image.network(
                imgPath!,
                fit: BoxFit.cover, // 이미지가 위젯 영역에 맞게 맞추도록 설정
                width: MediaQuery.of(context).size.width - 20, // 이미지 폭
                height: MediaQuery.of(context).size.width - 20, // 이미지 높이
              ),
            )
          ],
        );
      } else {
        // 앱에서는 Image.file 사용
        return Container(
          width: MediaQuery.of(context).size.width - 20,
          height: MediaQuery.of(context).size.width - 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            // 기타 다른 데코레이션 설정 (예: 그림자, 색상 등)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              File(imgPath!),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } else {
      return SizedBox(); // 이미지가 없을 때 빈 SizedBox 반환 또는 다른 대체 위젯
    }
  }



  void handleTagSelection(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  Future<void> addOnelineReview() async {
    try {
      String userId = 'user123';

      Map<String, dynamic> reviewData = {
        'content': _review.text,
        'userNo': userId,
        'cDateTime': FieldValue.serverTimestamp(),
        'observationTime': _observationTime,
        'docent': _docentOr,
      };

      // Add review data
      DocumentReference reviewReference = await _firestore.collection('exhibition').doc(widget.document).collection('onelineReview').add(reviewData);

      // Add tags to each review's subcollection
      CollectionReference tagsCollection = reviewReference.collection('tags');
      for (String tag in selectedTags) {
        await tagsCollection.add({'tagName': tag});
      }

      _review.clear();
      setState(() {
        selectedTags.clear();
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('리뷰가 성공적으로 등록되었습니다.', style: TextStyle(fontSize: 16),),
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
      print('리뷰 등록 중 오류 발생: $e');
    }
  }

  Widget buildToggleButton(int value, String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: _selectedValue == value ? Color(0xff464D40) : Colors.white,
        onPrimary: _selectedValue == value ? Colors.white : Colors.black,
        side: BorderSide(width: 1, color: Color(0xff464D40)),
      ),
      onPressed: () {
        setState(() {
          _selectedValue = value;
          _docentOr = _selectedValue == 0 ? "없음" : "있음";
        });
      },
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_exDetailData?['exTitle'] == null ? "" : "${_exDetailData?['exTitle']} 리뷰 작성", style: TextStyle(color: Colors.black, fontSize: 17),),
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
              Text("사진 업로드", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              Text("전시와 관련된 사진을 업로드 해주세요.", style: TextStyle(color: Colors.grey, fontSize: 13),),
              SizedBox(height: 20),
              InkWell(
                onTap: (){
                  getImage();
                },
                child:
                _imageFile != null ? _buildImageWidget() :
                Container(
                  width: MediaQuery.of(context).size.width - 20,
                  height: MediaQuery.of(context).size.width - 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffc0c0c0),width: 1 ),
                    color: Color(0xffececec),
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child: Icon(Icons.photo_library, color: Color(0xff464D40), size: 30,)
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  Text("리뷰 작성", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
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
                    hintText: "리뷰를 작성해주세요"
                ),
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Container(
                      width: 110,
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 18,),
                          SizedBox(width: 5,),
                          Text("관람 시간", style: TextStyle(fontSize: 17),),
                        ],
                      )
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(width: 1, color: Color(0xff464D40)),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: (){
                        showModalBottomSheet(
                          enableDrag : true,
                          isScrollControlled: true,
                          shape : RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove, size: 35,),
                                Text("관람 시간 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "30분";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("30분", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "1시간";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("1시간", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "1시간 30분";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("1시간 30분", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "2시간";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("2시간", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "2시간 30분";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("2시간 30분", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _observationTime = "3시간";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("3시간", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 0.1,
                                  ),
                                ),
                                SizedBox(height: 20,)
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Text(_observationTime),
                          SizedBox(width: 20,),
                          Icon(Icons.expand_more)
                        ],
                      )
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 110,
                    child: Row(
                      children: [
                        Icon(Icons.headset, size: 16,),
                        SizedBox(width: 5,),
                        Text("도슨트", style: TextStyle(fontSize: 17),),
                      ],
                    ),
                  ),
                  buildToggleButton(0, "없음"),
                  SizedBox(width: 10,),
                  buildToggleButton(1, "있음"),
                ],
              ),
              Text("* 음성 작품 해설", style: TextStyle(color: Colors.grey[500])),
              SizedBox(height: 40,),
              Text("태그 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Wrap(
                children: allTags.map((tag) {
                  bool isSelected = selectedTags.contains(tag);
                  return Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(isSelected ? Color(0xff464D40) : Colors.white),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all<double>(1.3), // 그림자 높이 설정
                      ),
                      onPressed: () {
                        handleTagSelection(tag);
                      },
                      child: Text(tag, style: TextStyle(fontSize: 15, color: isSelected ? Colors.white : Colors.black)),
                    ),
                  );
                }).toList(),
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
                      txtCheck ?
                      addOnelineReview() 
                      :showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('리뷰 내용을 작성해주세요.'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('확인'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("리뷰 등록", style: TextStyle(fontSize: 18),)
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

