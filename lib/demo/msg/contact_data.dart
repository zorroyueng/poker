import 'package:flutter/cupertino.dart';
import 'package:poker/base/adapter.dart';

class ContactData extends Data {
  final int id;
  final String url;
  final String name;
  final String lastMsg;

  ContactData({
    required this.id,
    required this.url,
    required this.name,
    required this.lastMsg,
  });

  @override
  ValueKey key() => ValueKey(id);
}
