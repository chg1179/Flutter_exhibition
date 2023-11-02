import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// 이미지 선택
class ImageSelector {
  final picker = ImagePicker();

  Future<XFile?> selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }
}

// 이미지 업로드
class ImageUploader {
  final String folderName;

  ImageUploader(this.folderName);

  Future<String> uploadImage(XFile imageFile) async {
    Uint8List? imageBytes = await imageFile.readAsBytes();

    FirebaseStorage storage = FirebaseStorage.instance;
    String folder = '$folderName/';
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = storage.ref().child('$folder$fileName.jpg');

    // SettableMetadata를 사용하여 이미지에 메타데이터 추가
    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg', // 이미지 유형에 맞게 content type 설정
    );

    UploadTask uploadTask = storageReference.putData(imageBytes, metadata);

    try {
      await uploadTask;
      String fullPath = storageReference.fullPath;
      String downloadUrl = await storage.ref(fullPath).getDownloadURL(); // 변경된 부분: 스토리지 경로로부터 다운로드 URL을 얻습니다.
      return downloadUrl;
    } catch (e) {
      print('Error: $e');
      return ''; // 또는 에러 처리를 적절히 해줄 수 있습니다
    }
  }
}