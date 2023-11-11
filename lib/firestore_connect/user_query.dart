import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Firestore에 사용자 정보 추가
Future<void> addUserFirestore(String collectionStr, String email, String hashedPassword, String randomSalt, String nickName, String phone, bool eventChecked) async {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final CollectionReference user = _fs.collection(collectionStr);
  await user.add({
    'email': email,
    'password': hashedPassword,
    'randomSalt' : randomSalt,
    'nickName': nickName,
    'phone': phone,
    'eventYn': eventChecked ? 'Y' : 'N',
    'joinDate': FieldValue.serverTimestamp(),
    'heat': 36.5,
    'status': 'U',
    'profileImage' : 'https://firebasestorage.googleapis.com/v0/b/exhibitionproject-fdba1.appspot.com/o/artist_images%2Fgreen_logo.png?alt=media&token=504ba42a-5385-484e-9a00-fa1ca7006363'
  });
}

Future<void> updateUserPassword(String collectionName, String documentId, String hashedPassword) async {
  await FirebaseFirestore.instance
      .collection(collectionName)
      .doc(documentId)
      .update({
        'password' : hashedPassword,
      });
}

// Firebase 예외 처리 함수
void firebaseException(FirebaseAuthException e) {
  if (e.code == 'weak-password') {
    print('The password provided is too weak.');
  } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
  } else {
    print(e.toString());
  }
}