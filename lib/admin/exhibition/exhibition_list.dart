import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/common_add_delete_button.dart';
import 'package:exhibition_project/admin/common_list.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_edit.dart';
import 'package:exhibition_project/admin/exhibition/exhibition_view.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/text_and_image.dart';
import 'package:flutter/material.dart';

class ExhibitionListPage extends StatelessWidget {
  const ExhibitionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExhibitionList();
  }
}

class ExhibitionList extends StatefulWidget {
  const ExhibitionList({super.key});

  @override
  State<ExhibitionList> createState() => _ExhibitionListState();
}

class _ExhibitionListState extends State<ExhibitionList> {
  Map<String, bool> checkedList = {};
  int displayLimit = 8;

  void loadMoreItems() {
    setState(() {
      displayLimit += 8;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonList(
      title: '전시회',
      children: [
        setImgTextList(
          'exhibition',
          'exTitle',
          (DocumentSnapshot document) => ExhibitionViewPage(document: document),
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
                MaterialPageRoute(builder: (context) => ExhibitionEditPage(document: null)),
              );
            },
            onDeletePressed: () {
              removeCheckList(context, checkedList, 'exhibition');
            },
          ),
        ),
      ],
    );
  }
}