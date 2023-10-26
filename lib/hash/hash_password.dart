import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashFunction {
  String hashPassword(String password, String salt) {
    final key = utf8.encode(password); // 비밀번호 -> 바이트로 인코딩
    final bytes = utf8.encode(salt); // 솔트 -> 바이트로 인코딩
    final hmacSha256 = Hmac(sha256, key); // HMAC-SHA256 해시 함수
    final digest = hmacSha256.convert(bytes); // 솔트와 비밀번호를 해싱
    return digest.toString(); // 해시값을 문자열로 반환
  }
}

// 비밀번호 해싱
String hashPassword(String password) {
  final salt = 'salt';
  final hashFunction = HashFunction();
  return hashFunction.hashPassword(password, salt);
}

// 비밀번호 일치 여부 확인
bool isPasswordValid(String inputPassword, String storedHashedPassword) {
  // 사용자가 입력한 비밀번호를 해시화
  // 비밀번호 해시화
  final salt = 'salt';
  final hashFunction = HashFunction(); // HashFunction 클래스의 인스턴스 생성
  final hashedPassword = hashFunction.hashPassword(inputPassword, salt);
  print(hashedPassword);
  // 저장된 해시된 비밀번호와 사용자가 입력한 해시된 비밀번호를 비교
  return hashedPassword == storedHashedPassword;
}