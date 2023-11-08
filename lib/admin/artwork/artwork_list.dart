import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/admin/artwork/artwork_edit.dart';
import 'package:exhibition_project/admin/artwork/artwork_view.dart';
import 'package:exhibition_project/admin/artwork/child_list.dart';
import 'package:exhibition_project/admin/common_add_delete_button.dart';
import 'package:exhibition_project/admin/common_list.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/style/button_styles.dart';
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
  int displayLimit = 8; // 출력 갯수

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
        ChildList(
          parentCollection: 'artist',
          childCollection: 'artist_artwork',
          parentName: 'artistName',
          childName: 'artTitle',
          loadMoreItems: loadMoreItems,
          displayLimit: displayLimit,
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArtworkEditPage(parentDocument: null, childData: null)),
              );
            },
            style: greenButtonStyle(),
            child: Text("추가"),
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}