import 'package:exhibition_project/admin/artist/artist_edit_addition.dart';
import 'package:exhibition_project/admin/artist/artist_edit_profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  FilePickerResult? file; // 이미지 파일의 정보
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
          appBar: AppBar(
            backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
            title: Center(
              child: Text(
                '작가',
                style: TextStyle(
                    color: Color.fromRGBO(70, 77, 64, 1.0),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 탭에 해당하는 페이지
                    ArtistEditProfilePage(moveToNextTab: moveToNextTab), // 다음 인덱스로 이동할 함수를 보냄
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