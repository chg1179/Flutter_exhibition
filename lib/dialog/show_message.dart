import 'package:flutter/material.dart';

showMessageDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 20),
        buttonPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)))
          ),
        ],
      );
    },
  );
}

showMoveDialog(BuildContext context, String message, Widget Function() pageBuilder){
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(60, 60, 60, 40),
        actionsPadding: EdgeInsets.fromLTRB(30, 0, 30, 30),
        content: Text(message, style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageBuilder()),
              );
            },
            child: Text('확인', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 77, 64, 1.0)))
          ),
        ],
      );
    },
  );
}