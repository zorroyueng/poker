import 'package:poker/base/db.dart';

class User extends DbTable {
  static const String kId = 'id';
  static const String kName = 'name';
  static const String kAge = 'age';
  static const String kSex = 'sex';
  static const String kIntro = 'intro';
  static const String kPicUrl = 'picUrl';

  final ColInt id = ColInt(name: kId, key: true);
  final ColStr name = ColStr(name: kName);
  final ColInt age = ColInt(name: kAge);
  final ColInt sex = ColInt(name: kSex);
  final ColStr introduce = ColStr(name: kIntro);
  final ColStr picUrl = ColStr(name: kPicUrl);

  User(super.map);

  @override
  void init(List<Col> columns) => columns.addAll([id, name, age, sex, introduce, picUrl]);

  @override
  String tName() => 'User';
}
