import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit_addition.dart';
import 'package:exhibition_project/admin/artist/artist_edit_profile.dart';
import 'package:flutter/material.dart';

class ArtistEditPage extends StatelessWidget {
  final DocumentSnapshot? document;
  const ArtistEditPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEdit(document: document)
    );
  }
}

class ArtistEdit extends StatefulWidget {
  final DocumentSnapshot? document;
  const ArtistEdit({super.key, required this.document});

  @override
  State<ArtistEdit> createState() => _ArtistEditState(document: document);
}

class _ArtistEditState extends State<ArtistEdit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DocumentSnapshot? document; // 받아온 값
  String? documentId; // 저장된 값
  bool documentSet = false; // document가 설정되었는지 확인하는 플래그
  String editKind = 'update'; // 추가하는지 저장하는지 확인하는 값. 수정 시 이전 값을 늦게 받아오는 이슈를 막기 위함

  _ArtistEditState({this.document}) {
    if (document != null) {
      documentId = document!.id;
      documentSet = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    settingdocument();
  }

  Future<void> settingdocument() async {
    if(widget.document != null){
      document = widget.document;
      setState(() {
        documentSet = true; // document 설정됨
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void moveToNextTab(docId, kind) {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
      if(_tabController.index != 0)
        setState(() {
          documentId = docId;
          editKind = kind;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 탭에 해당하는 페이지
                    ArtistEditProfilePage(moveToNextTab: moveToNextTab, document: document), // 다음 인덱스로 이동할 함수를 보냄
                    ArtistEditAdditionPage(documentId: documentId, editKind: editKind),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}