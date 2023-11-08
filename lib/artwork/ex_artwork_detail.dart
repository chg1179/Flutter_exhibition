import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/artist/artist_info.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';

class ExArtworkDetail extends StatefulWidget {
  final String doc;
  final String artDoc;

  const ExArtworkDetail({required this.doc, required this.artDoc});

  @override
  State<ExArtworkDetail> createState() => _ExArtworkDetailState();
}

class _ExArtworkDetailState extends State<ExArtworkDetail> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _artworkInfo;
  Map<String, dynamic>? _artistInfo;
  bool _loading = true;

  Future<void> _getArtworkData() async {
    final documentSnapshot = await _firestore.collection('artist').doc(widget.doc).collection('artist_artwork').doc(widget.artDoc).get();

    if (documentSnapshot.exists) {
      setState(() {
        _artworkInfo = documentSnapshot.data() as Map<String, dynamic>;
      });
    }
  }

  Future<void> _getArtistData() async {
    final documentSnapshot = await _firestore.collection('artist').doc(widget.doc).get();

    if (documentSnapshot.exists) {
      setState(() {
        _artistInfo = documentSnapshot.data() as Map<String, dynamic>;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getArtworkData();
    _getArtistData();
  }

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            icon: Icon(Icons.home, color: Colors.black),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body:
      _loading ? Center(child: CircularProgressIndicator())
      :CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          "assets/ex/ex1.png",
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
                                  _artworkInfo?['artTitle'],
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
                          SizedBox(height: 5,),
                          Text("${_artworkInfo?['artType']} / ${_artworkInfo?['artDate']}"),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistInfo(document: widget.doc)));
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            CircleAvatar(
                              radius: 30, // 반지름 크기 조절
                              backgroundImage: AssetImage("assets/ex/ex1.png"),
                            ),
                            SizedBox(width: 15),
                            Text(_artistInfo?['artistName'], style: TextStyle(fontSize: 16),)
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
                    // Container(
                    //   height: 200,
                    //   child: Center(child: Text("연관 작품이 없습니다.")),
                    // ),
                    SizedBox(height: 15),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        child: StreamBuilder(
                          stream: _firestore
                              .collection('artist')
                              .doc(widget.doc)
                              .collection('artist_artwork')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text('관련 작품이 없습니다.'),
                                );
                              }
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: ClampingScrollPhysics(),
                                child: Row(
                                  children: List.generate(snapshot.data!.docs.length, (index) {
                                    var artwork = snapshot.data?.docs[index];
                                    return Container(
                                      width: MediaQuery.of(context).size.width * 0.5, // 반 페이지만 표시
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: widget.doc, artDoc: artwork!.id)));
                                          },
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                height: 300,
                                                child: Image.asset(
                                                  "assets/ex/ex1.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8, bottom: 5, left: 5, right: 5),
                                                child: Text('${artwork?['artTitle']}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              );
                            }
                          },
                        )
                    )

                  ]
              ),
            ),
          ]
      ),
    );

  }

}
