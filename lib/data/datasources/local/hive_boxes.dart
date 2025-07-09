import 'package:hive/hive.dart';
import '../../../domain/models/breed.dart';

class HiveBoxes {
  static const String breedsBox = 'breeds';

  static Box<String> getBreedsBox() => Hive.box<String>(breedsBox);
}
