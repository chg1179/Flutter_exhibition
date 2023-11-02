import 'package:exhibition_project/community/comm_main.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:exhibition_project/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Ex_list(),
    );
  }
}

class Ex_list extends StatefulWidget {
  const Ex_list({super.key});

  @override
  State<Ex_list> createState() => _Ex_listState();
}

class _Ex_listState extends State<Ex_list> {
  final _search = TextEditingController();
  String _selectedOption = '최신순'; // 초기 선택값
  List<String> options = ['최신순', '인기순', '종료순'];
  bool _ongoing = true;
  bool _placeFlg = true;
  bool _categoryFlg = true;
  List<String> _placeSelectedOptions = ["전체"];
  List<String> _categorySelectedOptions = ["전체"];

  void _resetState() {
    setState(() {
      _placeFlg = true; // 지역 상태 초기화
      _categoryFlg = true; // 카테고리 상태 초기화
      _placeSelectedOptions = ["전체"]; // 선택된 지역 초기화
      _categorySelectedOptions = ["전체"]; // 선택된 카테고리 초기화
    });
  }

  String getOngoing(DateTime startDate, DateTime endDate) {
    DateTime currentDate = DateTime.now();

    if(currentDate.isBefore(startDate)){
      return "예정";
    }else if(currentDate.isBefore(endDate)) {
      return "진행중";
    } else {
      return "종료";
    }
  }

  Widget _exhibitionList() {
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('exhibition')
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('에러 발생: ${snap.error}'));
        }
        if (!snap.hasData) {
          return Center(child: Text('데이터 없음'));
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                  crossAxisSpacing: 10.0, // 열 간의 간격
                  mainAxisSpacing: 10.0, // 행 간의 간격
                  childAspectRatio: 2/5
              ),
              itemCount: snap.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snap.data!.docs[index];
                final exTitle = doc['exTitle'] as String;
                Timestamp startTimestamp = doc['startDate'] as Timestamp;
                DateTime startDate = startTimestamp.toDate();
                Timestamp endTimestamp = doc['endDate'] as Timestamp;
                DateTime endDate = endTimestamp.toDate();

                String? imagePath;

                final data = doc.data() as Map<String, dynamic>;
                if (data.containsKey('imagePath')) {
                  imagePath = data['imagePath'] as String;
                } else {
                  // 'imagePath' 필드가 문서 데이터에 존재하지 않는 경우, 이곳에서 처리할 수 있습니다
                  imagePath = null;
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('exhibition')
                      .doc(doc.id)
                      .collection('exhibition_image')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('데이터를 불러오는 중 오류가 발생했습니다: ${snapshot.error}');
                    }

                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final imageUrl = snapshot.data!.docs[0]['imageURL'] as String;
                      // 가져온 이미지 경로를 사용하여 UI에 표시할 수 있습니다.
                      // 이곳에서 이미지를 표시하거나, 리스트에 추가하는 등의 작업을 수행할 수 있습니다.

                      final galleryNo = doc['galleryNo'] as String;
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('gallery')
                            .doc(galleryNo)
                            .snapshots(),
                        builder: (context, gallerySnapshot) {
                          if (gallerySnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                          }
                          if (gallerySnapshot.hasData && gallerySnapshot.data!.exists) {
                            final galleryName = gallerySnapshot.data!['galleryName'] as String;
                            final galleryRegion = gallerySnapshot.data!['region'] as String;
                            final place = galleryName; // 갤러리 이름을 가져와서 place 변수에 할당

                            return InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) =>
                                        ExhibitionDetail(document: doc.id)));
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
                                      child: Image.network(imageUrl),
                                    ),
                                    Container(
                                        alignment: Alignment.centerLeft,
                                        padding: EdgeInsets.only(
                                            left: 17, top: 15, bottom: 5),
                                        decoration: BoxDecoration(
                                        ),
                                        child: Text(
                                            getOngoing(startDate, endDate),
                                            style: TextStyle(
                                              decoration: TextDecoration
                                                  .underline,
                                              decorationStyle: TextDecorationStyle
                                                  .double,
                                              decorationColor: Color(
                                                  0xff464D40),
                                              decorationThickness: 1.5,
                                            )
                                        )
                                    ),
                                    ListTile(
                                      title: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          child: Text(exTitle, style: TextStyle(
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
                                            child: Text("${place} / ${galleryRegion}", style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: Text(
                                                "${DateFormat('yyyy.MM.dd')
                                                    .format(
                                                    startDate)} ~ ${DateFormat(
                                                    'yyyy.MM.dd').format(
                                                    endDate)}"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Text('갤러리 정보 없음');
                          }
                        }
                      );
                    } else {
                      return Text('이미지 없음');
                    }

                  }
                );
              },
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    PlaceFlg placeFlg = PlaceFlg(placeFlg: _placeFlg, placeSelectedOptions: _placeSelectedOptions);

    List<String> selectedOptions = placeFlg.getSelectedPlaceOptions();
    _placeSelectedOptions = selectedOptions;

    int _currentIndex = 0;

    void _onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: SizedBox.shrink(),
        title: TextField(
          controller: _search,
          decoration: InputDecoration(
            border: InputBorder.none, // 테두리 없애는 부분
            enabledBorder: InputBorder.none, // 활성화된 상태의 테두리 없애는 부분
            hintText: "검색어를 입력하세요.",
            labelStyle: TextStyle(
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: -47),
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Color(0xff464D40)),
              onPressed: () {
                print("돋보기 눌럿다");
              },
            ),
          ),
          style: TextStyle(),
          cursorColor: Color(0xff464D40),
          onChanged: (newValue) {
            setState(() {});
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xffc4c4c4), // 그림자의 색상
                  offset: Offset(0, 1), // 그림자의 위치 (가로, 세로)
                  blurRadius: 3.0, // 그림자의 흐림 정도
                ),
              ],
            ),
            child: Row(
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.black,)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      elevation: MaterialStateProperty.all(0),
                    ),
                    onPressed: (){
                      showModalBottomSheet(
                          enableDrag : true,
                          shape : RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove, size: 35,),
                                Text("정렬 기준", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
                                TextButton(
                                    style: ButtonStyle(
                                      minimumSize: MaterialStateProperty.all(Size(500, 60)),
                                    ),
                                    onPressed: (){
                                      setState(() {
                                        _selectedOption = "최신순";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("최신순", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 120,
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
                                        _selectedOption = "인기순";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("인기순", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 120,
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
                                        _selectedOption = "종료순";
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text("종료순", style: TextStyle(fontSize: 17, color: Colors.black,),)
                                ),
                                SizedBox(
                                  width: 120,
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
                        Text("${_selectedOption} ", style: TextStyle(color: Colors.black, fontSize: 15)),
                        Icon(Icons.expand_more, color: Colors.black,)
                      ],
                    ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: IconButton(
                    icon: Icon(Icons.tune, color: Color(0xff464D40),),
                    onPressed: (){
                      showModalBottomSheet(
                        enableDrag : true,
                        isScrollControlled: true,
                        shape : RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15))),
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.88,
                            child: Column(
                              children: [
                                Icon(Icons.remove, size: 35,),
                                Text("필터 설정", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                SizedBox(height: 8,),
                                Divider(
                                  color: Colors.black,
                                  thickness: 0.1,
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text("전시중", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: BottomSheetSwitch(
                                        switchValue: _ongoing,
                                        valueChanged: (value) {
                                          _ongoing = value;
                                        },
                                      )
                                    )
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                  thickness: 0.1,
                                ),
                                PlaceFlg(placeFlg: _placeFlg, placeSelectedOptions: _placeSelectedOptions,),
                                Divider(
                                  color: Colors.black,
                                  thickness: 0.1,
                                ),
                                CategoryFlg(categoryFlg: _categoryFlg),
                                Divider(
                                  color: Colors.black,
                                  thickness: 0.1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 20,top: 10),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Reset(
                                        placeSelectedOptions: _placeSelectedOptions,
                                        onReset: _resetState,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xff464D40)),
                                              textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white,fontSize: 17)),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                              elevation: MaterialStateProperty.all(0),
                                              minimumSize: MaterialStateProperty.all(Size(270, 60)),
                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                            ),
                                            onPressed: (){
                                              print("찹아보기");
                                              Navigator.pop(context);
                                            },
                                            child: Text("찾아보기")
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          _exhibitionList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                },
                icon : Icon(Icons.home),
                color: Colors.black
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Ex_list()));
                },
                icon : Icon(Icons.account_balance, color: Colors.black)
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                },
                icon : Icon(Icons.comment),
                color: Colors.black
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
                },
                icon : Icon(Icons.library_books),
                color: Colors.black
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
                },
                icon : Icon(Icons.account_circle),
                color: Colors.black
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////전시중 스위치 클래스

class BottomSheetSwitch extends StatefulWidget {
  BottomSheetSwitch({required this.switchValue, required this.valueChanged});

  final bool switchValue;
  final ValueChanged valueChanged;

  @override
  _BottomSheetSwitch createState() => _BottomSheetSwitch();
}

class _BottomSheetSwitch extends State<BottomSheetSwitch> {
  bool _switchValue = false;

  @override
  void initState() {
    _switchValue = widget.switchValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CupertinoSwitch(
          value: _switchValue,
          onChanged: (bool value) {
            setState(() {
              _switchValue = value;
              widget.valueChanged(value);
            });
          },
        activeColor: Color(0xff464D40),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////지역바 클래스

class PlaceFlg extends StatefulWidget {
  const PlaceFlg({required this.placeFlg, required this.placeSelectedOptions});

  final bool placeFlg;
  final List<String> placeSelectedOptions;

  List<String> getSelectedPlaceOptions() {
    return placeSelectedOptions;
  }

  @override
  State<PlaceFlg> createState() => _PlaceFlgState();
}

class _PlaceFlgState extends State<PlaceFlg> {
  bool _placeFlg = true;

  @override
  void initState() {
    super.initState();
    _placeFlg = widget.placeFlg;
    _placeSelectedOptions = widget.placeSelectedOptions;
  }

  Icon _iconMore(){
    return Icon(Icons.expand_more, size: 30,);
  }

  Icon _iconLess(){
    return Icon(Icons.expand_less, size: 30,);
  }

  List<String> _placeSelectedOptions = ["전체"]; // 선택된 항목을 저장할 리스트

  void toggleOption(String option) {
    setState(() {
      if (option == "전체") {
        if (_placeSelectedOptions.contains("전체")) {
          _placeSelectedOptions.remove("전체");
        } else {
          _placeSelectedOptions = ["전체"];
        }
      } else {
        if (_placeSelectedOptions.contains("전체")) {
          _placeSelectedOptions.remove("전체");
        }
        if (_placeSelectedOptions.contains(option)) {
          _placeSelectedOptions.remove(option);
        } else {
          _placeSelectedOptions.add(option);
        }
      }
    });
  }

  Widget customButton(String label, bool selected) {
    return GestureDetector(
      onTap: () {
        toggleOption(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Color(0xff464D40) : Color(0xffF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xff464D40) : Color(0xffD4D8C8),
            width: 1,
          ),
        ),
        padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Color(0xff464D40)),
        ),
      ),
    );
  }

  Widget _placeSelectBtn() {
    if (_placeFlg) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              customButton("전체", _placeSelectedOptions.contains("전체")),
              customButton("서울", _placeSelectedOptions.contains("서울")),
              customButton("경기/인천", _placeSelectedOptions.contains("경기/인천")),
              customButton("부산/울산/경남", _placeSelectedOptions.contains("부산/울산/경남")),
              customButton("대구/경북", _placeSelectedOptions.contains("대구/경북")),
              customButton("광주/전라", _placeSelectedOptions.contains("광주/전라")),
              customButton("대전/충청/세종", _placeSelectedOptions.contains("대전/충청/세종")),
              customButton("강원", _placeSelectedOptions.contains("강원")),
              customButton("제주", _placeSelectedOptions.contains("제주")),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _placeFlg = !_placeFlg;
              print("_placeFlg: $_placeFlg");
            });
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text("지역", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _placeFlg ? _iconLess() : _iconMore(),
              )
            ],
          ),
        ),
        _placeSelectBtn()
      ],
    );
  }
}

/////////////////////////////////////////////////////////////////////////카테고리

class CategoryFlg extends StatefulWidget {
  const CategoryFlg({required this.categoryFlg});

  final bool categoryFlg;

  @override
  State<CategoryFlg> createState() => _CategoryFlgState();
}

class _CategoryFlgState extends State<CategoryFlg> {
  bool _categoryFlg = true;

  @override
  void initState() {
    super.initState();
    _categoryFlg = widget.categoryFlg;
  }

  Icon _iconMore(){
    return Icon(Icons.expand_more, size: 30,);
  }

  Icon _iconLess(){
    return Icon(Icons.expand_less, size: 30,);
  }

  List<String> _categorySelectedOptions = ["전체"]; // 선택된 항목을 저장할 리스트

  void toggleOption(String option) {
    setState(() {
      if (option == "전체") {
        if (_categorySelectedOptions.contains("전체")) {
          _categorySelectedOptions.remove("전체");
        } else {
          _categorySelectedOptions = ["전체"];
        }
      } else {
        if (_categorySelectedOptions.contains("전체")) {
          _categorySelectedOptions.remove("전체");
        }
        if (_categorySelectedOptions.contains(option)) {
          _categorySelectedOptions.remove(option);
        } else {
          _categorySelectedOptions.add(option);
        }
      }
    });
  }

  Widget customButton(String label, bool selected) {
    return GestureDetector(
      onTap: () {
        toggleOption(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Color(0xff464D40) : Color(0xffF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Color(0xff464D40) : Color(0xffD4D8C8),
            width: 1,
          ),
        ),
        padding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Color(0xff464D40)),
        ),
      ),
    );
  }

  Widget _categorySelectBtn() {
    if (_categoryFlg) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              customButton("전체", _categorySelectedOptions.contains("전체")),
              customButton("회화", _categorySelectedOptions.contains("회화")),
              customButton("미디어", _categorySelectedOptions.contains("미디어")),
              customButton("디자인", _categorySelectedOptions.contains("디자인")),
              customButton("사진", _categorySelectedOptions.contains("사진")),
              customButton("키즈아트", _categorySelectedOptions.contains("키즈아트")),
              customButton("특별전시", _categorySelectedOptions.contains("특별전시")),
              customButton("조각", _categorySelectedOptions.contains("조각")),
              customButton("설치미술", _categorySelectedOptions.contains("설치미술")),
              customButton("온라인전시", _categorySelectedOptions.contains("온라인전시")),
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _categoryFlg = !_categoryFlg;
              print("_placeFlg: $_categoryFlg");
            });
          },
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text("카테고리", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _categoryFlg ? _iconLess() : _iconMore(),
              )
            ],
          ),
        ),
        _categorySelectBtn()
      ],
    );
  }
}

///////////////////////////////////////////////////////////////////////////초기화 버튼~
class Reset extends StatefulWidget {
  const Reset({required this.placeSelectedOptions, required this.onReset});
  final List<String> placeSelectedOptions;
  final VoidCallback onReset;

  @override
  State<Reset> createState() => _ResetState();
}

class _ResetState extends State<Reset> {
  List<String> _placeSelectedOptions = ["전체"];

  @override
  void initState() {
    super.initState();
    _placeSelectedOptions = widget.placeSelectedOptions;
  }

  void _resetOptions() {
    setState(() {
      _placeSelectedOptions = ["전체"];
      widget.onReset(); // 초기화 버튼을 눌렀을 때 콜백 함수를 호출합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _resetOptions,
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          EdgeInsets.only(right: 5, left: 5, top: 10),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Color(0xff8c8c8c)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.replay, size: 23),
          Text("초기화", style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
