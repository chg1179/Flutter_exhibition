import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import '../firebase_storage/img_upload.dart';
import 'comm_detail.dart';
import 'comm_main.dart';

class CommEdit extends StatefulWidget {
  final String? documentId;

  CommEdit({Key? key, this.documentId}) : super(key: key);

  @override
  _CommEditState createState() => _CommEditState();
}

class _CommEditState extends State<CommEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  final ImageSelector selector = ImageSelector();
  late ImageUploader uploader;
  XFile? _imageFile;
  String? downloadURL;

  @override
  void initState() {
    super.initState();
    if (widget.documentId != null) {
      _loadPostData(widget.documentId!);
    }
  }

  Future<void> _loadPostData(String documentId) async {
    try {
      final documentSnapshot =
      await FirebaseFirestore.instance.collection('post').doc(documentId).get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final title = data['title'] as String;
        final content = data['content'] as String;
        final imageURL = data['imageURL'] as String?;

        setState(() {
          _titleCtr.text = title;
          _contentCtr.text = content;
          downloadURL = imageURL;
        });
      } else {
        print('게시글을 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _savePost() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference post = FirebaseFirestore.instance.collection("post");

      if (_imageFile != null) {
        try {
          await uploadImage();
        } catch (e) {
          print('이미지 업로드 중 오류 발생: $e');
        }
      }

      try {
        if (widget.documentId != null) {
          await post.doc(widget.documentId!).update({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            'write_date': DateTime.now(),
            'imageURL': downloadURL,
          });
        } else {
          await post.add({
            'title': _titleCtr.text,
            'content': _contentCtr.text,
            'write_date': DateTime.now(),
            'imageURL': downloadURL,
          });
        }

        _titleCtr.clear();
        _contentCtr.clear();
        // 이미지 선택 여부 초기화
        downloadURL = null;
        _imageFile = null; // 이미지 선택 여부 초기화
      } catch (e) {
        print('데이터 저장 중 오류가 발생했습니다: $e');
      }
    } else {
      print("제목과 내용을 입력해주세요");
    }
  }



  Future<void> getImage() async {
    XFile? pickedFile = await selector.selectImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    } else {
      print('이미지가 선택되지 않음');
    }
  }

  Future<void> uploadImage() async {
    if (_imageFile != null) {
      try {
        final uploader = ImageUploader('post_images');
        downloadURL = await uploader.uploadImage(_imageFile!);
        print('Uploaded to Firebase Storage: $downloadURL');
      } catch (e) {
        print('이미지 업로드 중 오류 발생: $e');
      }
    } else {
      // 이미지를 선택하지 않은 경우
      print('이미지를 선택하지 않았습니다. 이미지를 선택하지 않은 상태에서 글을 저장합니다.');
      downloadURL = null;
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
            _buildSelectedImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    if (_imageFile != null) {
      return Image.file(
        File(_imageFile!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (downloadURL != null && downloadURL!.isNotEmpty) {
      return Image.network(
        downloadURL!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      // 이미지가 선택되지 않은 경우에는 빈 컨테이너 반환
      return Container();
    }
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
        onPressed: getImage,
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
          widget.documentId != null ? '글 수정' : '글 작성',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _savePost().then((value) {
                if (widget.documentId != null) {
                  // 수정 버튼일 경우
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommDetail(document: widget.documentId!)));
                } else {
                  // 등록 버튼일 경우
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
                }
              });
            },
            child: Text(
              widget.documentId != null ? '수정' : '등록',
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
            ],
          ),
        ),
      ),
    );
  }
}
