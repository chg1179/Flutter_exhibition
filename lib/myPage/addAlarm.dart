import 'package:cloud_firestore/cloud_firestore.dart';

void addAlarm(String sessionUserId, String otherUserId, String content) async {
  //세션 유저 값얻기
  final userRef = FirebaseFirestore.instance.collection('user').doc(sessionUserId);

  try {
    // 세션 유저의 닉네임 가져오기
    final sessionUserDoc = await userRef.get();
    final sessionUserNickName = sessionUserDoc['nickName'];

    // 현재 시간 가져오기
    final currentTime = DateTime.now();

    // 상대 유저의 알람 서브컬렉션에 알림 추가
    final otherUserRef = FirebaseFirestore.instance.collection('user').doc(otherUserId);
    final otherUserAlarmRef = otherUserRef.collection('alarm');

    await otherUserAlarmRef.add({
      'content': content,
      'nickName': sessionUserNickName,
      'time': currentTime,
    });

    print('알림이 성공적으로 추가되었습니다.');
  } catch (e) {
    print('알림 추가 중 오류 발생: $e');
  }
}
