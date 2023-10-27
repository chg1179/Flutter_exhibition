import 'package:flutter/material.dart';

class CategoryInfo {
  final String imagePath;
  final String text;
  final Widget Function() page;

  CategoryInfo({
    required this.imagePath,
    required this.text,
    required this.page,
  });
}