import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GalleryInfo extends StatefulWidget {
  final String document;
  const GalleryInfo({required this.document});

  @override
  State<GalleryInfo> createState() => _GalleryInfoState();
}

class _GalleryInfoState extends State<GalleryInfo> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _galleryData;
  bool _isLoading = true;

  Future<void> openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    _getGalleryData();
  }

  void _getGalleryData() async {
    try {
      final documentSnapshot = await _firestore.collection('gallery').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _galleryData = documentSnapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
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
      _isLoading ? Center(child: CircularProgressIndicator())
      : CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate(
                  [
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          _galleryData?["imageURL"],
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
                                  "${_galleryData?['galleryName']} / ${_galleryData?['region']}",
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
                                Text(_galleryData?['addr'], style: TextStyle())
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
                                    child: Text("${_galleryData?['startTime']} ~ ${_galleryData?['endTime']}")
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
                                Text(_galleryData?['galleryClose'])
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
                                    child: Text(_galleryData?['galleryPhone'])
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
                                    child: Text(_galleryData?['galleryEmail'] == null ? "-" : _galleryData?['galleryEmail'])
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
                                openURL(_galleryData!['webSite'].toString());
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
                      child: Text(_galleryData?['galleryIntroduce'] == null ? "" : _galleryData?['galleryIntroduce']),
                    ),
                    SizedBox(height: 30,)
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 15),
                    //   child: Divider(
                    //     color: Color(0xff989898), // 선의 색상 변경 가능
                    //     thickness: 0.3, // 선의 두께 변경 가능
                    //   ),
                    // ),
                    // Container(
                    //   height: 30,
                    //   child: Stack(
                    //     children: [
                    //       Text(
                    //         "   진행 중 전시회",
                    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         left: 0,
                    //         child: Container(
                    //           height: 2.0, // 밑줄의 높이
                    //           width: 140,
                    //           color: Colors.black, // 밑줄의 색
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 200,
                    //   child: Center(child: Text("진행 중 전시가 없습니다.")),
                    // ),
                    // Container(
                    //   height: 30,
                    //   child: Stack(
                    //     children: [
                    //       Text(
                    //         "   예정 전시회",
                    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    //       ),
                    //       Positioned(
                    //         bottom: 0,
                    //         left: 0,
                    //         child: Container(
                    //           height: 2.0, // 밑줄의 높이
                    //           width: 140,
                    //           color: Colors.black, // 밑줄의 색
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   height: 200,
                    //   child: Center(child: Text("예정 전시가 없습니다.")),
                    // ),
                  ]
              ),
            ),
          ]
      ),
    );

  }

}
