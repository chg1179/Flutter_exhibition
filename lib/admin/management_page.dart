import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_list.dart';
import 'package:exhibition_project/admin/artwork/artwork_list.dart';
import 'package:exhibition_project/admin/gallery/gallery_list.dart';
import 'package:exhibition_project/model/management.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:flutter/material.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  // 카테고리를 리스트로 관리
  final List<CategoryInfo> categoryList = [
    CategoryInfo(imagePath: 'assets/ex/ex1.png', text: 'Artist', page: () => ArtistListPage()),
    CategoryInfo(imagePath: 'assets/ex/ex2.png', text: 'Artwork', page: () => ArtworkListPage()),
    CategoryInfo(imagePath: 'assets/ex/ex3.png', text: 'Exhibition', page: () => ExhibitionListPage()),
    CategoryInfo(imagePath: 'assets/ex/ex4.jpg', text: 'Gallery', page: () => GalleryListPage()),
  ];
  @override
  Widget build(BuildContext context) {
    //리스트 출력
    final List<Widget> itemWidgets = categoryList.map<Widget>((item) {
      return imageWithTextBtn(context, item.imagePath, item.text, item.page);
    }).toList();

    return Scaffold(
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.8),
        title: Text(
          '관리자 페이지',
          style: TextStyle(color: Color(0xff464D40))
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xff464D40),),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: ListView(
            children: itemWidgets
        ),
      ),
    );
  }
}