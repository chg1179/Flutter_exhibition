import 'package:exhibition_project/artist/artist_info.dart';
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
                          SizedBox(height: 5,),
                          Text("${_artworkInfo['art_size']} ${_artworkInfo['art_date']}"),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistInfo()));
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 30, // 반지름 크기 조절
                              backgroundImage: AssetImage("${widget.imagePath}"),
                            ),
                            SizedBox(width: 15),
                            Text(_artworkInfo['artist'], style: TextStyle(fontSize: 16),)
                          ],
                        ),
                      )
                    ), // 버튼
                    Divider(
                      color: Color(0xff989898), // 선의 색상 변경 가능
                      thickness: 0.3, // 선의 두께 변경 가능
                    ),
                    SizedBox(height: 10,),
                    Container(
                      height: 30,
                      child: Stack(
                        children: [
                          Text(
                            "    추천 작품",
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
                      child: Center(child: Text("연관 작품이 없습니다.")),
                    ),
                  ]
              ),
            ),
          ]
      ),
    );

  }

}
