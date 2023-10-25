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