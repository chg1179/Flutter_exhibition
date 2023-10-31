import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'comm_main.dart';

class CommAdd extends StatefulWidget {
  const CommAdd({Key? key});

  @override
  State<CommAdd> createState() => _CommAddState();
}

class _CommAddState extends State<CommAdd> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  File? _imageFile;

  // 글 등록
  void _addPost() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference post = FirebaseFirestore.instance.collection("post");

      String imagePath = '';

      if (_imageFile != null) {
        imagePath = await _saveImage(_imageFile!);
      }

      await post.add({
        'title': _titleCtr.text,
        'content': _contentCtr.text,
        'write_date' : DateTime.now(),
        'imagePath': imagePath,
      });

      _titleCtr.clear();
      _contentCtr.clear();
      setState(() {
        _imageFile = null; // 이미지 업로드 후 초기화
      });
    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  // 이미지 저장 함수
  Future<String> _saveImage(File imageFile) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory buskingDir = Directory('${dir.path}/busking');

    if (!await buskingDir.exists()) {
      await buskingDir.create(recursive: true);
    }

    final name = DateTime.now().millisecondsSinceEpoch.toString();
    File targetFile = File('${buskingDir.path}/$name.png');
    await imageFile.copy(targetFile.path);

    return targetFile.path;
  }

  // 이미지 선택
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget buildCommForm() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleInput(),
            _buildDivider(),
            SizedBox(height: 10),
            _buildImgButton(),
            _buildContentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      child: TextField(
        controller: _titleCtr,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 10),
          hintText: '제목을 입력해주세요.',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20),
      height: 2.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.black12,
    );
  }

  Widget _buildImgButton() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: IconButton(
        onPressed: _pickImage,
        icon: Icon(Icons.image_rounded, color: Colors.black26),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: TextField(
        maxLines: 10,
        maxLength: 300,
        controller: _contentCtr,
        decoration: InputDecoration(
          hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '글 작성',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: (){
              _addPost();
              Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
            },
            child: Text(
              '등록',
              style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildCommForm(),
              ),
              _buildSelectedImage(),
            ],
          ),
        ),
      ),
    );
  }
}
