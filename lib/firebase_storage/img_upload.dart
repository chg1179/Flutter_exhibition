import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadImageToFirebaseStorage(XFile imageFile) async {
  Uint8List fileBytes = await File(imageFile.path).readAsBytes(); // 이미지 파일을 바이트로 읽음
  String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // 타임스탬프로 고유한 파일 이름 설정
  Reference storageReference = FirebaseStorage.instance.ref().child('test/$fileName.jpg'); // 파일을 저장할 위치
  UploadTask uploadTask = storageReference.putData(fileBytes); //
  await uploadTask.whenComplete(() => null);
  String downloadURL = await storageReference.getDownloadURL();
  return downloadURL;
}