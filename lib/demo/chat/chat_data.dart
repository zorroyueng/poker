import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';

class ChatData extends Data {
  final int id;
  final bool my;
  final String picUrl;
  final String content;

  ChatData({
    required this.id,
    required this.my,
    required this.picUrl,
    required this.content,
  });

  @override
  ValueKey key() => ValueKey(id);
}