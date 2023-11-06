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
    'heat': '36.5',
    'status': 'U',
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