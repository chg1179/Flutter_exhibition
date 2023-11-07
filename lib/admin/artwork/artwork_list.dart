import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_edit.dart';
import 'package:exhibition_project/admin/artwork/artwork_view.dart';
import 'package:exhibition_project/admin/common_add_delete_button.dart';
import 'package:exhibition_project/admin/common_list.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/text_and_image.dart';
import 'package:flutter/material.dart';

class ArtworkListPage extends StatelessWidget {
  const ArtworkListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArtworkList();
  }
}

class ArtworkList extends StatefulWidget {
  const ArtworkList({super.key});

  @override
  State<ArtworkList> createState() => _ArtworkListState();
}

class _ArtworkListState extends State<ArtworkList> {
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
      title: '작품',
      children: [
        setChildImgTextList(
          'artist',
          'artist_artwork',
          'artTitle',
          (DocumentSnapshot document) => ArtworkViewPage(document: document),
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
                MaterialPageRoute(builder: (context) => ArtworkEditPage(document: null)),
              );
            },
            onDeletePressed: () {
              removeCheckList(context, checkedList, 'artwork');
            },
          ),
        ),
      ],
    );
  }
}