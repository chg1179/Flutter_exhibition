import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:flutter/material.dart';

Widget textFieldLabel(String text) {
  return SizedBox(
    width: 80, // 너비 조정
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget duplicateText(String message) {
  return Text(
    message,
    style: TextStyle(fontSize: 12, color: Color.fromRGBO(211, 47, 47, 1.0)),
  );
}

Widget textFieldType(TextEditingController textController, String kind) {
  return TextField(
      controller: textController,
      keyboardType: kind == 'year' ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: kind,
      )
  );
}

Widget textControllerBtn(
    BuildContext context,
    String kindText,
    String firstText,
    String secondText,
    List<List<TextEditingController>> textControllers,
    Function() onAdd,
    Function(int) onRemove,
    ) {
  double screenWidth = MediaQuery.of(context).size.width;
  double inkWidth = screenWidth / 13;
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kindText, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
        Column(
          children: [
            for (var i = 0; i < textControllers.length; i++)
              Row(
                children: [
                  SizedBox(
                    width: inkWidth * 3,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: textFieldType(textControllers[i][0], firstText),
                    ),
                  ),
                  SizedBox(
                    width: inkWidth * 5.5,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: textFieldType(textControllers[i][1], secondText),
                    ),
                  ),
                  SizedBox(
                    width: inkWidth,
                    child: IconButton(
                      icon: Icon(Icons.dangerous_outlined, size: 14), // 아이콘 크기를 변경해보세요 (예시로 20으로 변경)
                      onPressed: () {
                        onRemove(i);
                      },
                    ),
                  ),
                  if (i == textControllers.length - 1)
                    SizedBox(
                      width: inkWidth,
                      child: IconButton(
                        icon: Icon(Icons.add, size: 14), // 아이콘 크기를 변경해보세요 (예시로 20으로 변경)
                        onPressed: onAdd,
                      ),
                    ),
                ],
              ),
          ],
        ),
        if(textControllers.length == 0)
          Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
      ],
    ),
  );
}

// 수정 시 입력된 값을 가져옴
Future<void> settingTextList(String parentCollection, String childCollection, List<List<TextEditingController>> controllers, String documentId, String editKind, String firstText, String secondText) async {
  if (editKind == 'update') {
    QuerySnapshot artistDetails = await settingQuery(parentCollection, documentId, childCollection);
    if (artistDetails.docs.isNotEmpty) {
      controllers.clear();
      for (var award in artistDetails.docs) {
        var firstTxt = award[firstText]?.toString() ?? ''; // Null 체크 후 변환 또는 빈 문자열로 초기화
        var secondTxt = award[secondText]?.toString() ?? ''; // Null 체크 후 변환 또는 빈 문자열로 초기화
        controllers.add([
          TextEditingController(text: firstTxt),
          TextEditingController(text: secondTxt)
        ]);
      }
    } else {
      controllers.clear();
    }
  }
}