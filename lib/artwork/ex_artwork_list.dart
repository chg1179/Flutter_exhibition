import 'package:exhibition_project/myPage/mypage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../exhibition/ex_list.dart';
import '../review/review_list.dart';

void main() async{
  runApp(MaterialApp(
    home: ExArtworkList(),
  )
  );
}

class ExArtworkList extends StatefulWidget {
  ExArtworkList({Key? key});

  @override
  State<ExArtworkList> createState() => _ExArtworkListState();
}

class _ExArtworkListState extends State<ExArtworkList> {
  final _search = TextEditingController();
  String _selectedOption = '최신순'; // 초기 선택값
  List<String> options = ['최신순', '인기순', '종료순'];
  bool _ongoing = true;
  bool _placeFlg = true;
  bool _categoryFlg = true;
  List<String> _placeSelectedOptions = ["전체"];
  List<String> _categorySelectedOptions = ["전체"];

  final List<Map<String, dynamic>> _exList = [
    {'title': '차승언 개인전 <<Your love is better than life>>', 'place' : '씨알콜렉티브/서울', 'startDate':'2023.10.26', 'lastDate' : '2023.11.29', 'posterPath' : 'ex/ex1.png'},
    {'title': '김유경: Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.10.26', 'posterPath' : 'ex/ex2.png'},
    {'title': '원본 없는 판타지', 'place' : '온수공간/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex3.png'},
    {'title': '강태구몬, 닥설랍, 진택 : The Instant kids', 'place' : '러브 컨템포러리 아트/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex4.jpg'},
    {'title': '차승언 개인전 <<Your love is better than life>>', 'place' : '씨알콜렉티브/서울', 'startDate':'2023.10.26', 'lastDate' : '2023.11.29', 'posterPath' : 'ex/ex5.jpg'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex1.png'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.10.25', 'lastDate' : '2023.11.12', 'posterPath' : 'ex/ex2.png'},
    {'title': 'Tropical Maladys', 'place' : '상업화랑 용산/서울', 'startDate' : '2023.11.15', 'lastDate' : '2023.12.15', 'posterPath' : 'ex/ex3.png'},
  ];

  void _resetState() {
    setState(() {
      _placeFlg = true; // 지역 상태 초기화
      _categoryFlg = true; // 카테고리 상태 초기화
      _placeSelectedOptions = ["전체"]; // 선택된 지역 초기화
      _categorySelectedOptions = ["전체"]; // 선택된 카테고리 초기화
    });
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
        title: Text('작품', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), // 뒤로 가기 아이콘 및 글씨 색상을 검은색으로 설정
        leading: IconButton( // 뒤로가기 버튼을 추가
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
          elevation: 0
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
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ElevatedButton(
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
                              Text("정렬 기준", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
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
                                  child: Text("최신순", style: TextStyle(fontSize: 19, color: Colors.black,),)
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
                                  child: Text("인기순", style: TextStyle(fontSize: 19, color: Colors.black,),)
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
                                  child: Text("종료순", style: TextStyle(fontSize: 19, color: Colors.black,),)
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
                        Text("${_selectedOption} ", style: TextStyle(color: Colors.black),),
                        Icon(Icons.expand_more, color: Colors.black,)
                      ],
                    ),
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
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: Column(
                              children: [
                                Icon(Icons.remove, size: 35,),
                                Text("필터 설정", style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
                                SizedBox(height: 20,),
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
                                      SizedBox(width: 10,),
                                      Reset(
                                        placeSelectedOptions: _placeSelectedOptions,
                                        onReset: _resetState,
                                      ),
                                      SizedBox(width: 20,),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 330, // 각 열의 최대 너비
                    crossAxisSpacing: 15.0, // 열 간의 간격
                    mainAxisSpacing: 20.0, // 행 간의 간격
                    childAspectRatio: 2/3.9
                ),
                itemCount: _exList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      print("${_exList[index]['title']} 눌럿다");
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
                            child: Image.asset("assets/${_exList[index]['posterPath']}"),
                          ),

                          ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(_exList[index]['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(_exList[index]['place'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text("${_exList[index]['startDate']} ~ ${_exList[index]['lastDate']}"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
                onPressed: (){
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
            icon: Icon(Icons.comment,color: Colors.black),
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? Color(0xff464D40) : Color(0xffD4D8C8),
            width: 1,
          ),
        ),
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? Color(0xff464D40) : Color(0xffD4D8C8),
            width: 1,
          ),
        ),
        padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
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
