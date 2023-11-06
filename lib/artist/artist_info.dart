import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/exhibition/exhibition_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArtistInfo extends StatefulWidget {
  final String document;
  ArtistInfo({required this.document});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> with SingleTickerProviderStateMixin {
  bool isLiked = false;
  late TabController _tabController;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _artistData;
  List<Map<String, dynamic>>? _artistEducationData;
  List<Map<String, dynamic>>? _artistHistoryData;
  List<Map<String, dynamic>>? _artistAwardData;
  bool _isLoading = true;


  void _getArtistData() async {
    try {
      final documentSnapshot = await _firestore.collection('artist').doc(widget.document).get();
      if (documentSnapshot.exists) {
        setState(() {
          _artistData = documentSnapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }

  void _getEducationData() async {
    try {
      final querySnapshot = await _firestore
          .collection('artist')
          .doc(widget.document)
          .collection('artist_education')
          .orderBy('year')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> educationList = [];
        querySnapshot.docs.forEach((document) {
          educationList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistEducationData = educationList;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }


  void _getHistoryData() async {
    try {
      final querySnapshot = await _firestore.collection('artist').doc(widget.document).collection('artist_history').orderBy('year').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> historyList = [];
        querySnapshot.docs.forEach((document) {
          historyList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistHistoryData = historyList;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }

  void _getAwardsData() async {
    try {
      final querySnapshot = await _firestore.collection('artist').doc(widget.document).collection('artist_awards').orderBy('year').get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> awardsList = [];
        querySnapshot.docs.forEach((document) {
          awardsList.add(document.data() as Map<String, dynamic>);
        });

        setState(() {
          _artistAwardData = awardsList;
          _isLoading = false;
        });
      } else {
        print('정보를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
      _isLoading = false;
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
  }

  Widget buildSection(String title, List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left: 15),
            width: 130,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text("",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getEducationData();
    _getHistoryData();
    _getAwardsData();
    _getArtistData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalHeight = appBarHeight + statusBarHeight;
    double screenWidth = MediaQuery.of(context).size.width;
    double inkWidth = screenWidth / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(250.0),
        child: AppBar(
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.white,
              ),
              onPressed: toggleLike,
            ),
          ],
          flexibleSpace: Stack(
            children: [
              Image.asset(
                'assets/main/가로1.jpg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 16, bottom: 5),
                        child: Text(
                          _artistData?['artistName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Text(
                          _artistData?['expertise'],
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 130,
                right: 26,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/main/전시1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body:
      _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _artistEducationData == null ? SizedBox()
                        : Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text("학력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            width: 400,
                            height: _artistEducationData!.length * 40,
                            child: ListView.builder(
                              itemCount: _artistEducationData?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text("- ${_artistEducationData?[index]['year']} ${_artistEducationData?[index]['content']}"),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _artistHistoryData == null ? SizedBox()
                        : Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text("이력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            width: 400,
                            height: _artistHistoryData!.length * 40,
                            child: ListView.builder(
                              itemCount: _artistHistoryData?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text("- ${_artistHistoryData?[index]['year']} ${_artistHistoryData?[index]['content']}"),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    _artistAwardData == null ? SizedBox()
                        : Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Text("수상이력", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 10),
                            width: 400,
                            height: _artistAwardData!.length * 40,
                            child: ListView.builder(
                              itemCount: _artistAwardData?.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(5),
                                  child: Text("- ${_artistAwardData?[index]['year']} ${_artistAwardData?[index]['content']}"),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          child: Text(
                            '작품',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '전시회',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(width: 3.0, color: Colors.black),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - (totalHeight + 250),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          SingleChildScrollView(
                            child: Text("외않되" ),
                          ),
                          SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width - 40,
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('exhibition')
                                      .where('artistNo', isEqualTo: widget.document)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                        List<DocumentSnapshot> documents = snapshot.data!.docs;
                                        return GridView.builder(
                                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: inkWidth, // 각 열의 최대 너비
                                              crossAxisSpacing: 10.0, // 열 간의 간격
                                              mainAxisSpacing: 10.0, // 행 간의 간격
                                              childAspectRatio: 2/5
                                          ),
                                          itemCount: documents.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              child: Card(
                                                margin: const EdgeInsets.all(5.0),
                                                child: Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(5),
                                                        topRight: Radius.circular(5),
                                                      ),
                                                      child: Image.asset("assets/ex/ex1.png"),
                                                    ),
                                                    ListTile(
                                                      title: Padding(
                                                          padding: const EdgeInsets.only(
                                                              top: 5, bottom: 5),
                                                          child: Text(documents[index]['exTitle'], style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16),
                                                              maxLines: 3,
                                                              overflow: TextOverflow.ellipsis)
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                bottom: 5),
                                                            child: Text("${documents[index]['galleryName']} / ${documents[index]['region']}", style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12),),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                                bottom: 5),
                                                            child: Text(
                                                                "${DateFormat('yyyy.MM.dd').format(documents[index]['startDate'].toDate())} ~ ${DateFormat('yyyy.MM.dd').format(documents[index]['endDate'].toDate())}"),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return Text('No Data');
                                      }
                                    }
                                  },
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            ),
          )
        ]
      )
    );
  }
}
