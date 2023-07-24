import 'package:flutter/material.dart';
import 'package:poker/base/adapter.dart';

class FindData {
  final int id;
  final String head;
  final String name;
  final String content;
  final List<String> medias;
  final List<String> comments;

  FindData({
    required this.id,
    required this.head,
    required this.name,
    required this.content,
    required this.medias,
    required this.comments,
  });

  List<FindItemData> items() {
    List<FindItemData> lst = [];
    lst.add(FindItemData(type: Type.head, find: this));
    lst.add(FindItemData(type: Type.media, find: this));
    for (int i = 0; i < comments.length; i++) {
      lst.add(FindItemData(type: Type.comment, find: this, index: i));
    }
    return lst;
  }
}

enum Type {
  head,
  media,
  comment,
}

class FindItemData extends Data {
  final Type type;
  final FindData find;
  final int index;

  FindItemData({required this.type, required this.find, this.index = 0});

  @override
  ValueKey key() => ValueKey('${type}_${find.id}');
}
