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
            Container(
              width: MediaQuery.of(context).size.width * 0.434,
              height: 45,
              child: ElevatedButton(
                onPressed: onAddPressed,
                style: greenButtonStyle(),
                child: Text("추가하기", style: TextStyle(fontSize: 16),),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.44,
              height: 45,
              child: ElevatedButton(
                onPressed: onDeletePressed,
                style: greenButtonStyle(),
                child: Text('선택 항목 삭제', style: TextStyle(fontSize: 16),),
              ),
            ),
          ],
        ),
        SizedBox(height: 40),
      ],
    );
  }
}