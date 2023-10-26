import 'package:flutter/material.dart';

textFieldLabel(String txt){
  return Text(txt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

duplicateText(String message) {
  return Text(
    message,
    style: TextStyle(fontSize: 12, color: Color.fromRGBO(211, 47, 47, 1.0)),
  );
}
