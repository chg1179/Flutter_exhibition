import 'package:flutter/material.dart';

class CategoryInfo {
  final String imagePath; // 이미지 경로
  final String text; // 텍스트
  final Widget Function() page; // 이동할 페이지

  CategoryInfo({
    required this.imagePath,
    required this.text,
    required this.page,
  });
}