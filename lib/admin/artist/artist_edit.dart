import 'package:exhibition_project/admin/artist/artist_edit_addition.dart';
import 'package:exhibition_project/admin/artist/artist_edit_details.dart';
import 'package:exhibition_project/admin/artist/artist_edit_profile.dart';
import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/tab_wigets.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, String> formData = {}; // 다음 탭으로 값을 보내는 맵

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void moveToNextTab(Map<String, String> data) {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
      if (_tabController.index == 0) {
        formData = data;
      }
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
                    // 탭에 해당하는 페이지 위젯들을 추가합니다
                    ArtistEditProfilePage(moveToNextTab: moveToNextTab, formData: formData), // 다음 인덱스로 이동할 함수를 보냄
                    ArtistEditDetailsPage(moveToNextTab: moveToNextTab, formData: formData),
                    ArtistEditAdditionPage(moveToNextTab: moveToNextTab, formData: formData),
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