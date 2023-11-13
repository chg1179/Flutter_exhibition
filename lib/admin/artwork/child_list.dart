import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_view.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChildList extends StatefulWidget {
  const ChildList({
    Key? key,
    this.parentCollection,
    this.childCollection,
    this.parentName,
    this.childName,
    this.loadMoreItems,
    this.displayLimit,
  }) : super(key: key);

  final String? parentCollection;
  final String? childCollection;
  final String? parentName;
  final String? childName;
  final void Function()? loadMoreItems;
  final int? displayLimit;

  @override
  State<ChildList> createState() => _ChildListState();
}

// 작가 상위 컬렉션에 대한 아트 하위 컬렉션의 전체 리스트를 출력
class _ChildListState extends State<ChildList> {
  @override
  Widget build(BuildContext context) {
    int printCount = 0;
    return StreamBuilder(
      stream: getStreamData(widget.parentCollection!, widget.parentName!, false),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: SpinKitWave( // FadingCube 모양 사용
            color: Color(0xff464D40), // 색상 설정
            size: 30.0, // 크기 설정
            duration: Duration(seconds: 3), //속도 설정
          ));
        }

        int itemsToShow = widget.displayLimit! < snap.data!.docs.length
            ? widget.displayLimit!
            : snap.data!.docs.length;

        return Column(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(15, 10, 0, 15),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: itemsToShow,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snap.data!.docs[index];
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: listMapData(document, widget.parentCollection!, widget.childCollection!, widget.childName!, false),
                    builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        List<Map<String, dynamic>> childList = snapshot.data!;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: childList.map((data) {
                              if (printCount < widget.displayLimit!) {
                                Map<String, dynamic> parentData = getMapData(document);
                                Map<String, dynamic> childData = data;
                                String childDocumentId = childData['documentId']!.toString();
                                String text = childData[widget.childName!]!.toString();
                                String truncatedText = text.length <= 25 ? text : text.substring(0, 25);
                                if (text.length > 25) truncatedText += '...';

                                printCount++; // 일정 갯수만큼만 출력

                                return Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => ArtworkViewPage(parentDocument: document, childData: childData)),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child:
                                                childData['imageURL'] != null
                                                    ? Image.network(childData['imageURL'],fit: BoxFit.cover, width: 55, height: 55)
                                                    : Image.asset('assets/logo/basic_logo.png', fit: BoxFit.cover, width: 55, height: 55),
                                              ),
                                              SizedBox(width: 18),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(truncatedText, style: TextStyle(fontSize: 15)),
                                                  Text(parentData[widget.parentName!]!.toString(), style: TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }).toList(),
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      } else {
                        return SizedBox.shrink(); // 데이터가 null일 때 빈 값 반환
                      }
                    },
                  );
                },
              ),
            ),
            if (printCount <= widget.displayLimit!) // 데이터를 한 번에 모두 출력하지 않고 일정 갯수만큼 출력한 뒤, 더 보기하여 리스트 출력
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 45,
                child: ElevatedButton(
                  onPressed: widget.loadMoreItems!,
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(1), // 그림자 비활성화
                    backgroundColor: MaterialStateProperty.all(Color(0xffe4e5e0)),
                  ),
                  child: Text("더 보기", style: TextStyle(color: Colors.black, fontSize: 15)),
                ),
              ),
            SizedBox(height: 15),
          ],
        );
      },
    );
  }
}
