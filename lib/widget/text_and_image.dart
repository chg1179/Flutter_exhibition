import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/list_widgets.dart';
import 'package:flutter/material.dart';

// Firestore 데이터를 받아 리스트 목록을 출력하는 위젯
Widget setImgTextList(
    String collectionName,
    String name,
    Widget Function(DocumentSnapshot) pageBuilder,
    Map<String, bool> checkedList,
    void Function(Map<String, bool>) onChecked,
    void Function() loadMoreItems,
    int displayLimit,
    ) {
  return StreamBuilder(
    stream: getStreamData(collectionName, name, false),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
      if (!snap.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      // 일정 갯수씩 출력
      int itemsToShow = displayLimit < snap.data!.docs.length
          ? displayLimit
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
                Map<String, dynamic> data = getMapData(document);
                String text = data[name].toString();
                // 너무 긴 제목은 생략하여 표시
                String truncatedText = text.length <= 15 ? text : text.substring(0, 15) ;
                if(text.length > 15) truncatedText += '...';
                if (data[name] == null) return Container();
                return Row(
                  children: [
                    CheckBoxItem(
                      value: checkedList[document.id] ?? false,
                      onChanged: (bool? value) {
                        onChecked({
                          ...checkedList,
                          document.id: value ?? false,
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => pageBuilder(document)),
                              );
                            },
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: data['imageURL'] != null
                                      ? Image.network(data['imageURL'], width: 55, height: 55, fit: BoxFit.cover)
                                      : Image.asset('assets/logo/basic_logo.png', width: 55, height: 55, fit: BoxFit.cover),
                                ),
                                SizedBox(width: 18),
                                Text(truncatedText, style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        )
                    ),
                  ],
                );
              },
            ),
          ),
          if (displayLimit < snap.data!.docs.length)
            ElevatedButton(
              onPressed: loadMoreItems,
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0), // 그림자 비활성화
                backgroundColor: MaterialStateProperty.all(Colors.transparent), // 버튼의 배경색을 투명하게 설정
                overlayColor: MaterialStateProperty.all(Colors.transparent), // 버튼을 누르거나 호버할 때의 색을 투명하게 설정
              ),
              child: Text("더 보기", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)), // 버튼 텍스트 색상을 설정할 수 있습니다.
              ),
            ),
          SizedBox(height: 15),
        ],
      );
    },
  );
}