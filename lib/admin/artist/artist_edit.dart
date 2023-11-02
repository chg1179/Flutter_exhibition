import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit_addition.dart';
import 'package:exhibition_project/admin/artist/artist_edit_profile.dart';
import 'package:flutter/material.dart';

class ArtistEditPage extends StatelessWidget {
  const ArtistEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEdit()
    );
  }
}

class ArtistEdit extends StatefulWidget {
  const ArtistEdit({super.key});

  @override
  State<ArtistEdit> createState() => _ArtistEditState();
}

class _ArtistEditState extends State<ArtistEdit> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DocumentSnapshot? document; // 받아온 값
  String? documentId; // 저장된 값

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void moveToNextTab(docId) {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
      if(_tabController.index != 0)
        setState(() {
          documentId = docId;
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
                    ArtistEditAdditionPage(documentId: documentId),
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