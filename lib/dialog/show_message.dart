import 'package:flutter/material.dart';

showMessageDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인'),
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
        content: Text('회원가입이 성공적으로 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageBuilder()),
              );
            },
            child: Text("확인"),
          ),
        ],
      );
    },
  );
}