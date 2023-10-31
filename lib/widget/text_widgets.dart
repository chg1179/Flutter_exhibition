import 'package:flutter/material.dart';

Widget textFieldLabel(String text) {
  return SizedBox(
    width: 80, // 너비 조정
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
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
