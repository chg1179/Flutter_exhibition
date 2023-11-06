import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// 이미지 미리보기
Widget buildImageWidget({
  required XFile? imageFile,
  required String? imgPath,
  required String? selectImgURL,
  required String? defaultImgURL,
}) {
  if (imgPath != null) {
    if (kIsWeb) {
      // 웹 플랫폼에서는 Image.network 사용
      return Center(
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(imgPath!),
        ),
      );
    } else {
      // 앱에서는 Image.file 사용
      return Center(
        child: CircleAvatar(
          radius: 25,
          backgroundImage: FileImage(File(imgPath!)),
        ),
      );
    }
  } else {
    return (selectImgURL != null)
        ? Image.network(selectImgURL!)
        : Image.asset(defaultImgURL!, width: 50, height: 50, fit: BoxFit.cover);
  }
}