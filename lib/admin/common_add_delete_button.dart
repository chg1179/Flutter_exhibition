import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';

class CommonAddDeleteButton extends StatelessWidget {
  final Function()? onAddPressed;
  final Function()? onDeletePressed;

  const CommonAddDeleteButton({this.onAddPressed, this.onDeletePressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onAddPressed,
              style: greenButtonStyle(),
              child: Text("추가"),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: onDeletePressed,
              style: greenButtonStyle(),
              child: Text('선택 항목 삭제'),
            ),
          ],
        ),
        SizedBox(height: 40),
      ],
    );
  }
}