import 'dart:math';
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
// 32바이트의 랜덤한 값을 가진 salt 값 생성 -> 비밀번호를 안전하게 관리하기 가능
String generateRandomSalt() {
  final random = Random.secure();
  final List<int> saltBytes = List<int>.generate(32, (index) => random.nextInt(256));
  final String salt = base64Url.encode(saltBytes);
  return salt;
}

// 비밀번호 해싱
String hashPassword(String password, String randomSalt) {
  final salt = randomSalt;
  final hashFunction = HashFunction();
  return hashFunction.hashPassword(password, salt);
}

// 비밀번호 일치 여부 확인
bool isPasswordValid(String inputPassword, String storedHashedPassword, String randomSalt) {
  // 사용자가 입력한 비밀번호를 해시화하여 비교
  final hashFunction = HashFunction(); // HashFunction 클래스의 인스턴스 생성
  final hashedPassword = hashFunction.hashPassword(inputPassword, randomSalt);
  print(hashedPassword);
  // 저장된 해시된 비밀번호와 사용자가 입력한 해시된 비밀번호를 비교
  return hashedPassword == storedHashedPassword;
}