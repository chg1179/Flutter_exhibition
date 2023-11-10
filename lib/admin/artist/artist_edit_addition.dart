import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/artist_query.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ArtistEditAdditionPage extends StatelessWidget {
  final String? documentId; // 상위 컬렉션의 문서 id
  final String editKind; // 수정하는지 추가하는지 구분하기 위한 파라미터
  const ArtistEditAdditionPage({Key? key, required this.documentId, required this.editKind}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ArtistEditAddition(documentId: documentId, editKind: editKind);
  }
}

class ArtistEditAddition extends StatefulWidget {
  final String? documentId;
  final String editKind;
  const ArtistEditAddition({Key? key, required this.documentId, required this.editKind}) : super(key: key);

  @override
  _ArtistEditAdditionState createState() => _ArtistEditAdditionState();
}

class _ArtistEditAdditionState extends State<ArtistEditAddition> {
  List<List<TextEditingController>> educationControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  List<List<TextEditingController>> historyControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  List<List<TextEditingController>> awardsControllers = [
    [TextEditingController(), TextEditingController()]
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    if(widget.documentId != null && widget.editKind != null) {
      await settingTextList('artist', 'artist_education', educationControllers, widget.documentId!, widget.editKind, 'year', 'content');
      await settingTextList( 'artist', 'artist_history', historyControllers, widget.documentId!, widget.editKind, 'year', 'content');
      await settingTextList('artist', 'artist_awards', awardsControllers, widget.documentId!, widget.editKind, 'year', 'content');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(30),
        child: Container(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 항목, 컨트롤러, 생성, 삭제
                  textControllerBtn(context, '학력', 'year', 'content', educationControllers, () {
                      setState(() {
                        educationControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        educationControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  textControllerBtn(context, '활동', 'year', 'content', historyControllers, () {
                      setState(() {
                        historyControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        historyControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  textControllerBtn(context, '이력', 'year', 'content', awardsControllers, () {
                      setState(() {
                        awardsControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        awardsControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 입력된 세부 정보 추가
  Future<void> addDetails(List<List<TextEditingController>> controllers, String parentCollection, String childCollection) async {
    for (var i = 0; i < controllers.length; i++) {
      String year = controllers[i][0].text;
      String content = controllers[i][1].text;
      if (year.isNotEmpty && content.isNotEmpty) {
        await addArtistDetails(parentCollection, widget.documentId!, childCollection, year, content);
      }
    }
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () async {
      // 업데이트 하는 경우에 모든 필드를 삭제하고 입력된 정보를 삽입
        if(widget.editKind == 'update') {
          await deleteSubCollection('artist', widget.documentId!, 'artist_education');
          await deleteSubCollection('artist', widget.documentId!, 'artist_history');
          await deleteSubCollection('artist', widget.documentId!, 'artist_awards');
        }
        // 입력된 세부 정보 추가
        if(educationControllers.isNotEmpty) await addDetails(educationControllers, 'artist', 'artist_education');
        if(historyControllers.isNotEmpty) await addDetails(historyControllers, 'artist', 'artist_history');
        if(awardsControllers.isNotEmpty) await addDetails(awardsControllers, 'artist', 'artist_awards');

        // 저장 완료 메세지
        Navigator.of(context).pop();
        await showMoveDialog(context, '성공적으로 저장되었습니다.', () => ArtistList());
      },
      style: fullGreenButtonStyle(),
      child: boldGreyButtonContainer('저장하기'),
    );
  }
}
