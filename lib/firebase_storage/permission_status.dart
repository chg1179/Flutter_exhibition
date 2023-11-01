import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  // 파일 액세스 권한 확인
  PermissionStatus status = await Permission.storage.status;
  if (!status.isGranted) {
    // 권한이 없는 경우 권한 요청
    PermissionStatus permissionStatus = await Permission.storage.request();
    if (permissionStatus.isGranted) {
      // 권한이 부여된 경우
      print('파일 액세스 권한이 허용되었습니다.');
      return true;
    } else {
      // 권한이 거부된 경우
      print('파일 액세스 권한이 거부되었습니다.');
      return false;
      // 권한 요청 실패 시 사용자에게 안내 혹은 다른 작업 수행
    }
  } else {
    // 권한이 이미 부여된 경우
    print('파일 액세스 권한이 이미 허용되어 있습니다.');
    return true;
  }
}
