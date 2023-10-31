import 'package:flutter/material.dart';

class TabMoveController {
  final TabController tabController;

  TabMoveController(this.tabController);

  void moveToTab(int nextTabIndex) {
    if (nextTabIndex >= 0 && nextTabIndex < tabController.length) {
      tabController.animateTo(nextTabIndex);
    } else {
      print('유효하지 않은 탭 인덱스');
    }
  }
}