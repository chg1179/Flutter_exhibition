import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/artwork/ex_artwork_detail.dart';
import 'package:flutter/material.dart';

class MainArtWork extends StatefulWidget {
  const MainArtWork({super.key});

  @override
  State<MainArtWork> createState() => _MainArtWorkState();
}

class _MainArtWorkState extends State<MainArtWork> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;

    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
      child: StreamBuilder(
        stream: _firestore.collection('artist').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot artist = snapshot.data!.docs[index];
                return StreamBuilder(
                  stream: _firestore
                      .collection('artist')
                      .doc(artist.id)
                      .collection('artist_artwork')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> artworkSnapshot) {
                    if (!artworkSnapshot.hasData) {
                      return CircularProgressIndicator();
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                            crossAxisSpacing: 10, // 열 간의 간격
                            mainAxisSpacing: 5.0, // 행 간의 간격
                            childAspectRatio: 2.5/5
                        ),
                        itemCount: artworkSnapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot artwork = artworkSnapshot.data!.docs[index];
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ExArtworkDetail(doc: artist.id, artDoc: artwork.id,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.43,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(0xff5d5148),// 액자 테두리 색상
                                          width: 5, // 액자 테두리 두께
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xffb2b2b2), // 그림자 색상
                                            blurRadius: 2, // 흐림 정도
                                            spreadRadius: 1, // 그림자 확산 정도
                                            offset: Offset(0, 1), // 그림자 위치 조정
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(6),
                                      child: Image.network(
                                        artwork['imageURL'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, right: 5),
                                    child: Container(
                                        width: MediaQuery.of(context).size.width * 0.43,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xffcbcbcb), // 그림자 색상
                                              blurRadius: 0.5, // 흐림 정도
                                              spreadRadius: 1.5, // 그림자 확산 정도
                                              offset: Offset(1, 1.5), // 그림자 위치 조정
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${artwork['artTitle']}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                                            Text('${artist['artistName']}', style: TextStyle(fontSize: 12),),
                                            Text('${artwork['artDate']} / ${artwork['artType']}', style: TextStyle(fontSize: 11, color: Colors.grey[700]),),
                                          ],
                                        ),
                                      )
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
