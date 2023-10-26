import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _search = TextEditingController();

  ButtonStyle _buttonSt(){
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // 배경색 설정
      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.black,)), // 글꼴 스타일 설정
      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.black, width: 0.5),
        ),
      ),
    );
  }

  List<String> recommendedSearches = [
    "국립현대미술관",
    "아트페어",
    "서울시립미술관북서울관",
    "리움미술관",
  ];

  List<String> favourKey = [
    "현대미술",
    "감각적인",
    "섬세한",
    "절제",
    "정적인",
    "새로운",
    "형상화"
  ];

  List<String> popularSearches = [
    "고양이전시",
    "현대 미술",
    "리움미술관",
    "실외전시",
    "현대미술관",
    "사진전",
    "개인전",
    "앤디워홀",
  ];

  Widget recommendedTag(){
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List<Widget>.generate(recommendedSearches.length, (int index) {
        return ElevatedButton(
          onPressed: (){
            setState(() {
              _search.text = recommendedSearches[index];
            });
          },
          child: Text(recommendedSearches[index]),
          style: _buttonSt(),
        );
      }),
    );
  }

  Widget favourKeyword(){
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: List<Widget>.generate(favourKey.length, (int index) {
        return ElevatedButton(
          onPressed: (){
            setState(() {
              _search.text = favourKey[index];
            });
          },
          child: Text(favourKey[index]),
          style: _buttonSt(),
        );
      }),
    );
  }

  Widget popularKeywords() {
    List<Widget> keywordWidgets = [];
    for (int index = 0; index < popularSearches.length; index++) {
      keywordWidgets.add(
        ListTile(
          title: Row(
            children: [
              Text("${index + 1}      ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontStyle: FontStyle.italic, color: Color(0xff464D40)),),
              Text(popularSearches[index]),
            ],
          ),
          onTap: () {
            setState(() {
              _search.text = popularSearches[index];
            });
          },
        ),
      );
    }

    return Column(
      children: keywordWidgets,
    );
  }

  Widget _NoSearch(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 20),
          child: Text("추천 검색어", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30, right: 30,),
            child: recommendedTag()
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 20),
          child: Text("취향분석 맞춤 키워드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 30, right: 30,),
            child: favourKeyword()
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 10),
          child: Text("인기 검색어", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: popularKeywords(),
        )
      ],
    );
  }

  Widget _SearchIsTabBar(){
    return TabBar(
      tabs: [
        Tab(text: "전시",),
        Tab(text: "작가",),
        Tab(text: "전시관",),
        Tab(text: "작품",),
        Tab(text: "칼럼",)
      ],
      labelColor: Color(0xff464D40),
      unselectedLabelColor: Color(0xff879878),
      indicatorColor: Color(0xff464D40),
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _SearchIs(){
    return Container(
        height: 200,
        child: TabBarView(
          children: [
            Column(
              children: [
                Text("전시")
              ],
            ),
            Column(
              children: [
                Text("작가")
              ],
            ),
            Column(
              children: [
                Text("전시관")
              ],
            ),
            Column(
              children: [
                Text("작품")
              ],
            ),
            Column(
              children: [
                Text("칼럼")
              ],
            ),
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 5,
        child: ListView(
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "전시, 전시관, 작가, 작품, 컬럼 검색",
                    labelStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffD4D8C8),
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff464D40),
                        width: 1,
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Color(0xff464D40)),
                        onPressed: () {
                        },
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 18),
                  cursorColor: Color(0xff464D40),
                  onChanged: (newValue) {
                    setState(() {});
                  },
                ),
              ),
              if (_search.text.isEmpty) _NoSearch() else _SearchIsTabBar(),
              if (_search.text.isNotEmpty) _SearchIs(),
            ],
          ),
        ]
        ),
      ),
    );
  }
}
