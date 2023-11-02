import 'package:flutter/material.dart';

Widget textFieldLabel(String text) {
  return SizedBox(
    width: 90, // 너비 조정
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
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
    String kindText,
    List<List<TextEditingController>> textControllers,
    Function() onAdd,
    Function(int) onRemove,
    ) {
  return Container(
    padding: EdgeInsets.all(10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(kindText),
        Column(
          children: [
            for (var i = 0; i < textControllers.length; i++)
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child:textFieldType(textControllers[i][0], 'year'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child:textFieldType(textControllers[i][1], 'content'),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.dangerous_outlined),
                            onPressed: () {
                              onRemove(i);
                            },
                          ),
                          if (i == textControllers.length - 1)
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: onAdd,
                            ),
                        ],
                      ),
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