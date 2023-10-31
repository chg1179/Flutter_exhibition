import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';

class GalleryInfo extends StatefulWidget {
  final String imagePath;
  const GalleryInfo({required this.imagePath});

  @override
  State<GalleryInfo> createState() => _GalleryInfoState();
}

Map<String, dynamic> _galleryInfo = {
  'gallery_name': '국립아시아문화전당(ACC)/광주',
  'address': '광주 동구 문화전당로 38',
  'start_time': '10:00',
  'end_time': '18:00',
  'gallery_close': '월요일, 1월 1일',
  'gallery_phone': '1899-5566',
  'gallery_email': 'gfdge@naver.com'
};

class _GalleryInfoState extends State<GalleryInfo> {

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
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
                          "assets/${widget.imagePath}",
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
                                  _galleryInfo['gallery_name'],
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
                        ],
                      ),
                    ), // 상단 내용 패딩
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("주소", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Text(_galleryInfo['address'], style: TextStyle())
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("운영시간", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text("${_galleryInfo['start_time']} ~ ${_galleryInfo['end_time']}")
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("휴관일", style: TextStyle( fontWeight: FontWeight.bold),)
                                ),
                                Text(_galleryInfo['gallery_close'])
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("연락처", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text(_galleryInfo['gallery_phone'])
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                    width: 100,
                                    child: Text("이메일", style: TextStyle(fontWeight: FontWeight.bold),)
                                ),
                                Container(
                                    width: 250,
                                    child: Text(_galleryInfo['gallery_email'])
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 40%에 해당하는 버튼 크기
                          child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                minimumSize: MaterialStateProperty.all<Size>(Size(120, 40)),
                                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 10),
                                ),
                                foregroundColor: MaterialStateProperty.all<Color>(Color(0xff000000)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: Colors.black, style: BorderStyle.solid)
                                  ),
                                ),
                              ),
                              onPressed: (){
                              },
                              child: Text("전시관 홈페이지")
                          ),
                        ),
                      ),
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
