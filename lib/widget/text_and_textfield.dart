import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextAndTextField extends StatelessWidget {
  final String txt;
  final TextEditingController controller;
  final String kind;

  const TextAndTextField(this.txt, this.controller, this.kind);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        textFieldLabel(txt),
        Expanded(
          child: TextFieldInput(controller, kind),
        ),
      ],
    );
  }
}

// 국가를 선택하는 함수를 받음
class ButtonTextAndTextField extends StatelessWidget {
  final String txt;
  final String btnTxt;
  final TextEditingController controller;
  final String kind;
  final void Function()? countrySelect;

  const ButtonTextAndTextField(this.txt, this.btnTxt, this.controller, this.kind, this.countrySelect);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        textFieldLabel(txt),
        Expanded(
          child: TextFieldInput(controller, kind),
        ),
        SizedBox(width: 30),
        ElevatedButton(
          onPressed: countrySelect,
          style: greenButtonStyle(),
          child: Text(btnTxt),
        ),
      ],
    );
  }
}


class TextFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final String kind;

  const TextFieldInput(this.controller, this.kind);

  @override
  Widget build(BuildContext context) {
    final isIntroduce = kind == 'introduce';
    final isNationality = kind == 'nationality';
    final isTime = kind == 'time';
    final borderSide = BorderSide(
      color: Color.fromRGBO(70, 77, 64, 1.0),
      width: 1.0,
    );
    return TextFormField(
      enabled: !(isNationality || isTime),
      controller: controller,
      autofocus: true,
      maxLines: isIntroduce ? 8 : 1,
      keyboardType: kind == 'phone' ? TextInputType.phone : TextInputType.text,
      inputFormatters: [
        isIntroduce ? LengthLimitingTextInputFormatter(1000) : LengthLimitingTextInputFormatter(30),
      ],
      decoration: InputDecoration(
        hintText: isNationality
            ? '국가를 선택해 주세요.'
            : isTime ? '시간을 선택해 주세요.' : null,
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        focusedBorder: isIntroduce
            ? OutlineInputBorder(borderSide: borderSide)
            : UnderlineInputBorder(borderSide: borderSide),
        enabledBorder: isIntroduce
            ? OutlineInputBorder(borderSide: borderSide)
            : UnderlineInputBorder(borderSide: borderSide),
      ),
    );
  }
}
