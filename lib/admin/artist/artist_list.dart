import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artist/artist_edit.dart';
import 'package:exhibition_project/admin/artist/artist_view.dart';
import 'package:exhibition_project/admin/common_add_delete_button.dart';
import 'package:exhibition_project/admin/common_list.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/widget/text_and_image.dart';
import 'package:flutter/material.dart';

class ArtistListPage extends StatelessWidget {
  const ArtistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArtistList();
  }
}

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
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
      title: 'Artist',
      children: [
        setImgTextList(
          'artist',
          'artistName',
          (DocumentSnapshot document) => ArtistViewPage(document: document),
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
        CommonAddDeleteButton(
          onAddPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArtistEditPage(document: null)),
            );
          },
          onDeletePressed: () {
            removeCheckList(context, checkedList, 'artist');
          },
        ),
      ],
    );
  }
}