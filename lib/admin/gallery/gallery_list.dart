import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/common_add_delete_button.dart';
import 'package:exhibition_project/admin/common_list.dart';
import 'package:exhibition_project/admin/gallery/gallery_edit.dart';
import 'package:exhibition_project/admin/gallery/gallery_view.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/text_and_image.dart';
import 'package:flutter/material.dart';

class GalleryListPage extends StatelessWidget {
  const GalleryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GalleryList();
  }
}

class GalleryList extends StatefulWidget {
  const GalleryList({super.key});

  @override
  State<GalleryList> createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> {
  Map<String, bool> checkedList = {}; // 각 문서의 체크 상태를 저장하는 맵. 체크시 true 상태가 됨.
  int displayLimit = 8;

  void loadMoreItems() {
    setState(() {
      displayLimit += 8; // "더 보기" 버튼을 누를 때마다 10개씩 추가로 출력
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonList(
      title: '갤러리',
      children: [
        setImgTextList(
          'gallery',
          'galleryName',
          (DocumentSnapshot document) => GalleryViewPage(document: document),
          checkedList,
          (Map<String, bool> newCheckedList) {
            setState(() {
              checkedList = newCheckedList;
              print(checkedList);
            });
          },
          loadMoreItems,
          displayLimit,
        ),
        Center(
          child: CommonAddDeleteButton(
            onAddPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryEditPage(document: null)),
              );
            },
            onDeletePressed: () {
              removeCheckList(context, checkedList, 'gallery');
            },
          ),
        ),
      ],
    );
  }
}