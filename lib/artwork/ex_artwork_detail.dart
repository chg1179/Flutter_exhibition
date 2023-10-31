import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';

class ExArtworkDetail extends StatefulWidget {
  final String imagePath;
  const ExArtworkDetail({required this.imagePath});

  @override
  State<ExArtworkDetail> createState() => _ExArtworkDetailState();
}

Map<String, dynamic> _artworkInfo = {
  'art_title': '서로',
  'art_material': '캔버스에 먹, 아크릴',
  'art_size': '53x45cm',
  'art_date': '2017',
  'artist': '이정식',
};

class _ExArtworkDetailState extends State<ExArtworkDetail> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
            },
            icon: Icon(Icons.home, color: Colors.black),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          "${widget.imagePath}",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15,top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  _artworkInfo['art_title'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                  onPressed: (){},
                                  icon: Icon(Icons.favorite_border)
                              )
                            ],
                          ),
                          Text(_artworkInfo['art_material']),
                          Text("${_artworkInfo['art_size']} ${_artworkInfo['art_date']}"),
                        ],
                      ),
                    ), // 상단 내용 패딩
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: InkWell(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30, // 반지름 크기 조절
                              backgroundImage: AssetImage("assets/${widget.imagePath}"),
                            ),
                            SizedBox(width: 8,),
                            Text("차승언")
                          ],
                        ),
                      )
                    ), // 버튼
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text("국립아시아문화전당은 전 세계인들이 공감할 수 있는 동시대 주요 주제와 이슈, 아시아를 비롯한 세계 역사와 문화에 대한 다학제적 연구와 창제작을 기반으로 한 다양한 전시를 선보이고 있습니다. 교류에서 시작하여 창조와 연구, 교육으로 직접 순환되는 아시아 문화의 발전소가 되어 다양한 시각에서 문화예술 콘텐츠를 생산하고, 이를 전시로 시민들에게 선보임으로써 함께 참여하고, 공감하는 자리를 마련하고자 합니다."),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Divider(
                        color: Color(0xff989898), // 선의 색상 변경 가능
                        thickness: 0.3, // 선의 두께 변경 가능
                      ),
                    ),
                    Container(
                      height: 30,
                      child: Stack(
                        children: [
                          Text(
                            "   진행 중 전시회",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              height: 2.0, // 밑줄의 높이
                              width: 140,
                              color: Colors.black, // 밑줄의 색
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      child: Center(child: Text("진행 중 전시가 없습니다.")),
                    ),
                    Container(
                      height: 30,
                      child: Stack(
                        children: [
                          Text(
                            "   예정 전시회",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              height: 2.0, // 밑줄의 높이
                              width: 140,
                              color: Colors.black, // 밑줄의 색
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 200,
                      child: Center(child: Text("예정 전시가 없습니다.")),
                    ),
                  ]
              ),
            ),
          ]
      ),
    );

  }

}
