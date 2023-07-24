import 'package:poker/base/adapter.dart';
import 'package:poker/demo/demo_helper.dart';
import 'package:poker/demo/find/find_data.dart';

class FindProvider extends Provider<FindItemData> {
  @override
  Future<List<FindItemData>> getData({int from = 0, int? limit}) => Future.delayed(const Duration(seconds: 2)).then(
        (_) {
          List<FindData> lst = DemoHelper.findData(from, limit!);
          List<FindItemData> result = [];
          for (FindData find in lst) {
            result.addAll(find.items());
          }
          return result;
        },
      );

  @override
  int? pageLimit() => 20;

  @override
  List<Stream>? triggers() => null;
}
